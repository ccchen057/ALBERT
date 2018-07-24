#include "MaxRectsBinPack.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <math.h>
#include <cstdio>

struct JobInfo {
	int app;
	int input_file;
	int VMsize;
	int VMtype;
	int time;
	int min_node;
};

int checkInsert(std::vector<rbp::Rect> packedRect, rbp::MaxRectsBinPack bin, int total_time, int jobNo)
{
	if (packedRect.size() > 0)
	{
		for(size_t j = 0; j < packedRect.size(); ++j)
		{
			printf("Packed Job %d to (x,y)=(%d,%d), (w,h)=(%d,%d). Free space left: %.2f%%\n", jobNo, packedRect[j].x, packedRect[j].y, packedRect[j].width, packedRect[j].height, 100.f - bin.Occupancy()*100.f);

		}
	}
	else
	{
		printf("Failed! Could not find a proper position to pack this rectangle into. Skipping this one.\n");
	}

	fflush(stdout);
	return std::max(packedRect[0].x + packedRect[0].width, total_time);
}

int main(int argc, char **argv) {

	if (argc < 6) {
		printf("Usage: %s num_job P num_node num_core_per_node file sample", argv[0]);
		return 0;
	}

	int num_job = atoi(argv[1]);
	double P = atof(argv[2]);
	int num_node = atoi(argv[3]);
	int num_core_per_node = atoi(argv[4]);
	FILE *fp_s = fopen(argv[5], "r");
	int num_sample = atoi(argv[6]);

	struct JobInfo jobinfo[num_job];
        memset(jobinfo, 0, sizeof(jobinfo));

	//Sum of execution time in default configs
	int W = 0;
	for (int i = 0; i < num_job; ++i) {

		int default_time;
		fscanf(fp_s, "%d", &jobinfo[i].app);
		fscanf(fp_s, "%d", &jobinfo[i].input_file);
		fscanf(fp_s, "%d", &default_time);
		fscanf(fp_s, "%d", &jobinfo[i].min_node);
		W += default_time;
	}
	printf("Total default time: %d\n", W);

	int binWidth = W;
	int binHeight = num_node * num_core_per_node;

	int NP = ceil(num_job * P);
	printf("Number of prime jobs: %d\n", NP);

	int optimized_total_time = INT_MAX;

	using namespace rbp;

	for(int s = 0; s < num_sample; ++s) {

		int total_time = INT_MIN;
	
		MaxRectsBinPack bin;
		bin.Init(binWidth, binHeight, false, num_node);
		MaxRectsBinPack::FreeRectChoiceHeuristic heuristic = MaxRectsBinPack::RectBottomLeftRule;


		for (int i = 0; i < NP; ++i) {
			printf("Job %d : Phase 1\n", i + 1);

			int app = jobinfo[i].app;
			int input_file = jobinfo[i].input_file;
			int min_node = jobinfo[i].min_node;

			std::vector<Rect> packedRect = bin.Insert(W, 0, heuristic, false, app, input_file, min_node);

			total_time = checkInsert(packedRect, bin, total_time, i + 1);
		}

		for(int i = NP; i < num_job; ++i) {
			printf("Job %d : Phase 2\n", i + 1);

			int app = jobinfo[i].app;
			int input_file = jobinfo[i].input_file;
			int min_node = jobinfo[i].min_node;

			std::vector<Rect> packedRect = bin.Insert(0, 0, heuristic, true, app, input_file, min_node);
			total_time = checkInsert(packedRect, bin, total_time, i + 1);
		}

		optimized_total_time = std::min(total_time, optimized_total_time);
	}

	printf("Optimized total time: %d\n", optimized_total_time);

	return 0;
}
