package edu.carleton.duotao;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class Interval {
    double lower;
    double upper;
    public Interval(double lower, double upper) {
        this.lower = lower;
        this.upper = upper;
    }
}
public class LineSplitter {

    public static void main(String[] args) {
        try {
            Double[] lines = readLines(args[0]);
            goMatlab(lines, 0.1, 0.05);
        } catch (Exception e) {
            System.out.println("Exception reading or writing file");
            e.printStackTrace();
            System.exit(0);
        }
    }

    private static void goMatlab(Double[] lines, double minIntervalFraction, double margin) throws Exception{
        List<List<Double>> split = split(lines, minIntervalFraction);
        Interval[] intervals = addMargin(split, margin);
        generateMatlabFile(intervals, split);
    }

    private static Double[] readLines(String path) throws Exception {
        FileReader fr = new FileReader("lines.txt");
        BufferedReader br = new BufferedReader(fr);
        String[] sp;
        String s;
        int count = 0;
        ArrayList<Double> res = new ArrayList<>();
        while((s = br.readLine()) != null) {
            sp = s.split("\\s+");
            System.out.println("Data in " + sp[1]);
            res.add(Double.parseDouble(sp[1]));
            count++;
        }
        System.out.println("Total:" + count);
        fr.close();
        return res.toArray(new Double[res.size()]);
    }

    private static List<List<Double>> split(Double[] nums, double minIntervalFraction) {
        int[][] dp = new int[nums.length][nums.length];
        int[][] divs = new int[nums.length][nums.length];

        // get the non-divisible regions [i, j]
        for (int i = 0; i < nums.length; i++) {
            for (int j = i; j < nums.length; j++) {
                if (!isDivisible(nums, i, j, minIntervalFraction)) {
                    dp[i][j] = 1;
                    divs[i][j] = -1;
                }
            }
        }
        // fill in the rest of the dp and divs
        for (int length = 1; length <= nums.length; length++) {
            for (int start = 0; start <= nums.length - length; start++) {
                int end = start + length - 1;
                if (dp[start][end] == 0) {
                    dp[start][end] = Integer.MAX_VALUE;
                    for (int div = start; div < end; div++) {
                        if (dp[start][end] > dp[start][div] + dp[div + 1][end]) {
                            dp[start][end] = dp[start][div] + dp[div + 1][end];
                            divs[start][end] = div;
                        }
                    }
                }
            }
        }
        System.out.println("dp:");
        p2D(dp);
        System.out.println("divs:");
        p2D(divs);
        List<List<Double>> result = new ArrayList<>();
        recoverSolution(result, nums, divs, 0, nums.length - 1);
        return result;
    }

    private static void recoverSolution(List<List<Double>> res, Double[] nums, int[][] divs, int start, int end) {
        if (divs[start][end] == -1) {
            res.add(Arrays.asList(Arrays.copyOfRange(nums, start, end + 1)));
        } else {
            recoverSolution(res, nums, divs, start, divs[start][end]);
            recoverSolution(res, nums, divs, divs[start][end] + 1, end);
        }
    }

    private static boolean isDivisible(Double[] nums, int i, int j, double minIntervalFraction) {
        // get the smallest gap
        double minGap = Double.MAX_VALUE;
        double length = nums[j] - nums[i];
        for (int k = i + 1; k <= j; k++) {
            minGap = Math.min(minGap, nums[k] - nums[k - 1]);
        }
        return minGap < (length * minIntervalFraction);
    }

    private static Interval[] addMargin(List<List<Double>> data, double margin) {
        Interval[] intervals = new Interval[data.size()];
        for (int i = 0; i < data.size(); i++) {
            double l = data.get(i).get(0);
            double h = data.get(i).get(data.get(i).size() - 1);
            double bot = l - (h - l) * margin;
            double top = h + (h - l) * margin;
            bot = bot < 0 ? 0 : bot;
            intervals[i] = new Interval(bot, top);
        }
        return intervals;
    }

    private static void generateMatlabFile(Interval[] intervals, List<List<Double>> lineSplitted) throws Exception {
        String code;
        PrintWriter writer = new PrintWriter("main.m", "UTF-8");
        for (int i = 0; i < intervals.length; i++) {
            code = "multiple_lines_searcher('data', " + intervals[i].lower + ", " + intervals[i].upper + ", [";
            for (int j = 0; j < lineSplitted.get(i).size(); j++) {
                if (j == lineSplitted.get(i).size() - 1) {
                    code += lineSplitted.get(i).get(j) + "])";
                } else {
                    code += lineSplitted.get(i).get(j) + ", ";
                }
            }
            writer.println(code);
        }
        writer.close();
    }

    private static void p2D(int[][] arr) {
        for (int i = 0; i < arr.length; i++) {
            for (int j = 0; j < arr[0].length; j++) {
                System.out.print(arr[i][j] + " ");
            }
            System.out.println();
        }
    }
}
