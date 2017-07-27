# code to merge new week coherence results into main results
# example use:
# directory structure:
# ./main/<line_xx>/<week_xx>/<channels>
# ./new/<line_xx>/<week_xx>/<channels>
# python ./main ./new
# This will merge all line search results of ./new into ./main

import argparse
import os
import shutil


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("main", help="main results")
    parser.add_argument("new", help="new results")
    return parser.parse_args()


def merge(main_dir, new_dir):
    for f in os.listdir(new_dir):
        if os.path.isdir(os.path.join(new_dir, f)):
            mdir = os.path.join(main_dir, f)
            ndir = os.path.join(new_dir, f)
            if os.path.isdir(mdir):
                merge(mdir, ndir)
            else:
                shutil.copytree(ndir, mdir)
        else:
            print "File " + new_dir + "/" + f + " is not copied."


if __name__ == "__main__":
    args = parse_args()
    mainDir = args.main
    newDir = args.new
    merge(mainDir, newDir)