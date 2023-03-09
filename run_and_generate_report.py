#!/usr/bin/env python3

import argparse
import logging
import os
import sys
import subprocess
import glob
import openpyxl

#setting logger
logger = logging.getLogger('make_result_files.py')
logger.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

stream_handler = logging.StreamHandler()
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)


def parse_args():
    parser = argparse.ArgumentParser(description='make_result_file')
    parser.add_argument('--dataset_path', type=str, required=True, help='Path to KITTI dataset')
    parser.add_argument('--output_dir', type=str, required=True, help='Path to output directory')
    args = parser.parse_args()
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    args = parser.parse_args()
    return args


def createFolder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        logger.error('Creating directory. ' +  directory)
        sys.exit(1)


def run_rtapmap_all_features(output_dir, feature_num):
    for index in range(feature_num):
        logger.info('{}th feature start!'.format(index))
        createFolder(output_dir + str(index))
        try:
            output_text = subprocess.check_output([
                '/root/rtabmap_install/bin/rtabmap-kitti_dataset',
                '--Rtabmap/PublishRAMUsage', 'true',
                '--Rtabmap/DetectionRate', '2',
                '--Rtabmap/CreateIntermediateNodes', 'true',
                '--RGBD/LinearUpdate', '0',
                '--GFTT/QualityLevel', '0.01',
                '--GFTT/MinDistance', '7',
                '--SuperPoint/ModelPath', '/root/Documents/RTAB-Map/superpoint.pt',
                '--OdomF2M/MaxSize', '3000',
                '--Mem/STMSize', '30',
                '--Kp/MaxFeatures', '750',
                '--Kp/DetectorStrategy', '{}'.format(index),
                '--Vis/MaxFeatures', '1500',
                '--Vis/FeatureType', '{}'.format(index),
                '--output', '/root/result/{}'.format(index),
                '--gt', '/root/Documents/RTAB-Map/data_odometry_poses/dataset/poses/07.txt',
                '/root/Documents/RTAB-Map/data_odometry_gray/dataset/sequences/07'],
                encoding='utf-8')
        except subprocess.CalledProcessError:
            logger.error('Fail to excute {}th feature.'.format(index))
            sys.exit(1)
        logger.info('{}th feature finish!'.format(index))
        logger.info('Trying to save output text')
        with open(output_dir+'{}.txt'.format(index), 'w') as file:
            file.write(output_text)
        logger.info('Save complete!')


def parse_time_data(output_dir):
    logger.info('Parsing time data')
    time_dataset = {}
    feature_name = ['SURF', 'SIFT', 'ORB', 'FAST/FREAK',
                    'FAST/BRIEF', 'GFTT/FREAK', 'GFTT/BRIEF', 'BRISK',
                    'GFTT/ORB', 'KAZE', 'ORB-OCTREE', 'SuperPoint',
                    'SURF/FREAK', 'GFTT/DAISY', 'SURF/DAISY', 'PyDetector']
    file_path_list = glob.glob(output_dir+'*.txt')
    for file_path in file_path_list:
        time_data = {'camera':{}, 'odom':{}, 'slam':{}}

        with open(file_path, 'r') as file:
            lines = file.readlines()

        carmera_time = []
        odom_time = []
        slam_time = []
        for line in lines:
            words = line.split()
            if words and words[0] == 'Iteration':
                carmera_time.append(int(words[3].split('=')[-1][:-3]))
                odom_time.append(int(words[5].split('=')[-1][:-3]))
                slam_time.append(int(words[6].split('=')[-1][:-3]))

        time_data['camera']['average'] = sum(carmera_time) / len(carmera_time)
        time_data['camera']['median'] = sorted(carmera_time)[len(carmera_time)//2]
        time_data['camera']['max'] = max(carmera_time)
        time_data['camera']['min'] = min(carmera_time)

        time_data['odom']['average'] = sum(odom_time) / len(odom_time)
        time_data['odom']['median'] = sorted(odom_time)[len(odom_time)//2]
        time_data['odom']['max'] = max(odom_time)
        time_data['odom']['min'] = min(odom_time)

        time_data['slam']['average'] = sum(slam_time) / len(slam_time)
        time_data['slam']['median'] = sorted(slam_time)[len(slam_time)//2]
        time_data['slam']['max'] = max(slam_time)
        time_data['slam']['min'] = min(slam_time)

        index = int(file_path.split('.')[0].split('/')[-1])
        time_dataset[feature_name[index]] = time_data
    logger.info('Parsing done')
    return time_dataset


def write_excel(time_dataset, output_dir):
    logger.info('Trying to write data in excel format')
    workbook = openpyxl.load_workbook('/root/time_data_format.xlsx', data_only=True)
    worksheet = workbook.active
    row = 2
    for name, time_data in time_dataset.items():
        worksheet.cell(row, 1, name)
        for index, (type, data) in enumerate(time_data.items()):
            worksheet.cell(row+index, 2, type)
            for i, value in enumerate(data.values()):
                worksheet.cell(row+index, 3+i, value)
        row += 3
    workbook.save(output_dir+'time_result.xlsx')
    logger.info('Finsh!')


if __name__ == '__main__':
    args = parse_args()
    createFolder(args.output_dir)
    run_rtapmap_all_features(args.output_dir, 16)
    time_dataset = parse_time_data(args.output_dir)
    write_excel(time_dataset, args.output_dir)
