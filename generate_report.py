import argparse

def generate_report(output_dir):
    # implementation of report generation
    pass

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output_dir', type=str, required=True,
                        help='Output directory for report')
    args = parser.parse_args()
    generate_report(args.output_dir)
