import argparse

def evaluate_performance(dataset_path):
    # implementation of performance evaluation
    pass

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dataset_path', type=str, required=True,
                        help='Path to KITTI dataset')
    args = parser.parse_args()
    evaluate_performance(args.dataset_path)
