import argparse

def run_experiment(dataset_path):
    # implementation of experiment
    pass

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dataset_path', type=str, required=True,
                        help='Path to KITTI dataset')
    args = parser.parse_args()
    run_experiment(args.dataset_path)
