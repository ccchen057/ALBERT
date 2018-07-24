/** @file MaxRectsBinPack.cpp
	@author Jukka Jylänki

	@brief Implements different bin packer algorithms that use the MAXRECTS data structure.

	This work is released to Public Domain, do whatever you want with it.
*/
#include <algorithm>
#include <utility>
#include <iostream>
#include <limits>

#include <cassert>
#include <cstring>
#include <cmath>

#include <cstdio>
#include <sstream>

#include "MaxRectsBinPack.h"

#define NUM_TYPE_VM 3
#define	L_VM 6
#define	M_VM 3
#define	S_VM 1

#define DEBUG true

namespace rbp {

using namespace std;

struct JobInfo
{
	int app;
	int input_file;
	int VMsize;
	int VMtype;
	int time;
};

MaxRectsBinPack::MaxRectsBinPack()
:binWidth(0),
binHeight(0)
{
}

MaxRectsBinPack::MaxRectsBinPack(int width, int height, bool allowFlip, int bin)
{
	Init(width, height, allowFlip, bin);
}

void MaxRectsBinPack::Init(int width, int height, bool allowFlip, int bin)
{
	binAllowFlip = allowFlip;
	binWidth = width;
	binHeight = height;
	numBin = bin;

	Rect n;
	n.x = 0;
	n.y = 0;
	n.width = width;
	n.height = height;

	usedRectangles.clear();

	freeRectangles.clear();
	freeRectangles.push_back(n);
}

std::vector<Rect> MaxRectsBinPack::Insert(int width, int height, FreeRectChoiceHeuristic method, bool isOptimized, int app, int input_file, int min_node)
{
	std::vector<Rect> newNode;
	// Unused in this function. We don't need to know the score after finding the position.
	int score1 = std::numeric_limits<int>::max();
	int score2 = std::numeric_limits<int>::max();

	if (DEBUG == true)
	{
		for(size_t j = 0; j < freeRectangles.size(); ++j)
		{
			printf("\tfreeRectangles: %d %d %d %d\n", freeRectangles[j].x, freeRectangles[j].y, freeRectangles[j].width, freeRectangles[j].height);
		}printf("\n");
	}
	

	switch(method)
	{
		//case RectBestShortSideFit: newNode = FindPositionForNewNodeBestShortSideFit(width, height, score1, score2); break;
		case RectBottomLeftRule: newNode = FindPositionForNewNodeBottomLeft(width, height, score1, score2, isOptimized, app, input_file, min_node); break;
		//case RectContactPointRule: newNode = FindPositionForNewNodeContactPoint(width, height, score1); break;
		//case RectBestLongSideFit: newNode = FindPositionForNewNodeBestLongSideFit(width, height, score2, score1); break;
		//case RectBestAreaFit: newNode = FindPositionForNewNodeBestAreaFit(width, height, score1, score2); break;
	}
		
	if (newNode.size() == 0)
		return newNode;

	for(size_t i = 0; i < newNode.size(); ++i)
	{
		size_t numRectanglesToProcess = freeRectangles.size();
		for(size_t j = 0; j < numRectanglesToProcess; ++j)
		{
			if (SplitFreeNode(freeRectangles[j], newNode[i]))
			{
				freeRectangles.erase(freeRectangles.begin() + j);
				--j;
				--numRectanglesToProcess;
			}
		}
		PruneFreeList();
		usedRectangles.push_back(newNode[i]);
	}

	/*PruneFreeList();
	
	for(size_t i = 0; i < newNode.size(); ++i) {
		usedRectangles.push_back(newNode[i]);
	}*/
	// Need to be changed to vector
	return newNode;
}

/*void MaxRectsBinPack::Insert(std::vector<RectSize> &rects, std::vector<Rect> &dst, FreeRectChoiceHeuristic method)
{
	dst.clear();

	while(rects.size() > 0)
	{
		int bestScore1 = std::numeric_limits<int>::max();
		int bestScore2 = std::numeric_limits<int>::max();
		int bestRectIndex = -1;
		Rect bestNode;

		for(size_t i = 0; i < rects.size(); ++i)
		{
			int score1;
			int score2;
			Rect newNode = ScoreRect(rects[i].width, rects[i].height, method, score1, score2);

			if (score1 < bestScore1 || (score1 == bestScore1 && score2 < bestScore2))
			{
				bestScore1 = score1;
				bestScore2 = score2;
				bestNode = newNode;
				bestRectIndex = i;
			}
		}

		if (bestRectIndex == -1)
			return;

		PlaceRect(bestNode);
		dst.push_back(bestNode);
		rects.erase(rects.begin() + bestRectIndex);
	}
}

void MaxRectsBinPack::PlaceRect(const Rect &node)
{
	size_t numRectanglesToProcess = freeRectangles.size();
	for(size_t i = 0; i < numRectanglesToProcess; ++i)
	{
		if (SplitFreeNode(freeRectangles[i], node))
		{
			freeRectangles.erase(freeRectangles.begin() + i);
			--i;
			--numRectanglesToProcess;
		}
	}

	PruneFreeList();

	usedRectangles.push_back(node);
}

Rect MaxRectsBinPack::ScoreRect(int width, int height, FreeRectChoiceHeuristic method, int &score1, int &score2) const
{
	Rect newNode;
	score1 = std::numeric_limits<int>::max();
	score2 = std::numeric_limits<int>::max();
	switch(method)
	{
	case RectBestShortSideFit: newNode = FindPositionForNewNodeBestShortSideFit(width, height, score1, score2); break;
	//case RectBottomLeftRule: newNode = FindPositionForNewNodeBottomLeft(width, height, score1, score2); break;
	//case RectContactPointRule: newNode = FindPositionForNewNodeContactPoint(width, height, score1); 
	//	score1 = -score1; // Reverse since we are minimizing, but for contact point score bigger is better.
	//	break;
	//case RectBestLongSideFit: newNode = FindPositionForNewNodeBestLongSideFit(width, height, score2, score1); break;
	//case RectBestAreaFit: newNode = FindPositionForNewNodeBestAreaFit(width, height, score1, score2); break;
	}

	// Cannot fit the current rectangle.
	if (newNode.height == 0)
	{
		score1 = std::numeric_limits<int>::max();
		score2 = std::numeric_limits<int>::max();
	}

	return newNode;
}*/

/// Computes the ratio of used surface area.
float MaxRectsBinPack::Occupancy() const
{
	unsigned long usedSurfaceArea = 0;
	for(size_t i = 0; i < usedRectangles.size(); ++i)
		usedSurfaceArea += usedRectangles[i].width * usedRectangles[i].height;

	return (float)usedSurfaceArea / (binWidth * binHeight);
}

JobInfo op_function(int app, int input_file, int deadline, int num_node_min[], int num_node_max[]) {
	using namespace std;
	stringstream ss;
	ss << app << " ";
	ss << input_file << " ";
	ss << deadline << " ";
	for (int i = 0; i < NUM_TYPE_VM; ++i)
	{
		ss << num_node_min[i];
		ss << " ";
		ss << num_node_max[i];
		ss << " ";
	}

	//string cmd = "sh optimizer/fullrun_op_job.sh";
	string cmd = "sh ../optimizer/optimize_job.sh";
	cmd = cmd+" "+ss.str();
	
	printf("\tcmd: %s\n", cmd.c_str());

	char buffer[128];
	string result = "";
	FILE* pipe = popen(cmd.c_str(), "r");
	if (!pipe) throw std::runtime_error("popen() failed!");
	try {
		while (!feof(pipe)) {
		if (fgets(buffer, 128, pipe) != NULL)
			result += buffer;
		}
	} catch (...) {
		pclose(pipe);
		throw;
	}
	pclose(pipe);

	if (DEBUG == true)
	{
		printf("\tresult: %s", result.c_str());
	}
	
	JobInfo jobinfo;
	jobinfo.app = app;
	jobinfo.input_file = input_file;

	std::istringstream ss2(result);
	std::string token;

	vector<string> r;
	while(getline(ss2, token, ',')) {
		r.push_back(token);
	}

	jobinfo.VMtype = atoi(r.at(0).c_str());
	jobinfo.VMsize = atoi(r.at(1).c_str());
	jobinfo.time = atoi(r.at(2).c_str());

	if (DEBUG == true)
	{
		printf("\tjobinfo: %d %d %d %d %d\n", jobinfo.app, jobinfo.input_file, jobinfo.VMtype, jobinfo.VMsize, jobinfo.time);
	}

	return jobinfo;
}

std::vector<Rect> MaxRectsBinPack::FindPositionForNewNodeBottomLeft(int width, int height, int &bestY, int &bestX, bool isOptimized, int app, int input_file, int min_node) const
{
	std::vector<Rect> finalNode;
	finalNode.clear();

	bestY = std::numeric_limits<int>::max();
	bestX = std::numeric_limits<int>::max();

	//srand(time(NULL));
	//int min_node = rand();

	printf("freeRectangles.size(): %d\n", int(freeRectangles.size()));
	for(size_t i = 0; i < freeRectangles.size(); ++i)
	{
		// find the bound of left side
		// and store all candidate nodes to candidateNode
		int boundL = freeRectangles[i].x;
		std::vector<Rect> candidateNode;
		candidateNode.clear();
		for(size_t j = i; j < freeRectangles.size(); ++j)
		{
			if (freeRectangles[j].x <= boundL && freeRectangles[j].x + freeRectangles[j].width > boundL)
			{
				Rect tmpNode;
				tmpNode.x = boundL;
				tmpNode.y = freeRectangles[j].y;
				tmpNode.width = freeRectangles[j].width;
				tmpNode.height = freeRectangles[j].height;
				candidateNode.push_back(tmpNode);
			}
		}

		// find the bound of right side
		auto minmax_candidateNode = std::minmax_element(candidateNode.begin(), candidateNode.end(),
			[] (Rect const& lhs, Rect const& rhs) {return lhs.x + lhs.width < rhs.x + rhs.width;});
		int boundR = minmax_candidateNode.first->x + minmax_candidateNode.first->width;
		//if (DEBUG == true)
			printf("\tboundL: %d, boundR: %d\n", boundL, boundR);

		// sort candidateNode by y
		std::sort(candidateNode.begin(), candidateNode.end(),
			[] (Rect const& lhs, Rect const& rhs) {return lhs.y < rhs.y;});
	
		if (DEBUG == true)
		{
			for(size_t j = 0; j < candidateNode.size(); ++j)
			{
				printf("\tcandidate: %d %d %d %d\n", candidateNode[j].x, candidateNode[j].y, candidateNode[j].width, candidateNode[j].height);
			}printf("\n");
		}

		// update the candidateNode
		int binSize = binHeight / numBin;
		if (DEBUG == true)
		{
			printf("\tbinSize: %d\n", binSize);
		}
		for(size_t j = 0; j < candidateNode.size(); ++j)
		{
			candidateNode[j].width = boundR - boundL;

			if ((candidateNode[j].y / binSize) != ((candidateNode[j].y + candidateNode[j].height - 1) / binSize))
			{
				Rect tmpNode;
				tmpNode.x = boundL;
				tmpNode.y = binSize * (candidateNode[j].y / binSize + 1);
				tmpNode.width = boundR - boundL;
				tmpNode.height = candidateNode[j].y + candidateNode[j].height - binSize * (candidateNode[j].y / binSize + 1);
				candidateNode.push_back(tmpNode);
				
				candidateNode[j].height = binSize * (candidateNode[j].y / binSize + 1) - candidateNode[j].y;
			}
		}
		if (DEBUG == true)
		{
			for(size_t j = 0; j < candidateNode.size(); ++j)
			{
				printf("\tcandidate: %d %d %d %d\n", candidateNode[j].x, candidateNode[j].y, candidateNode[j].width, candidateNode[j].height);
			}printf("\n");
		}

		// calculate available space for different type of VM
		int availableNode[numBin][binSize];
		memset(availableNode, 0, sizeof(int) * numBin * binSize);
		for(size_t j = 0; j < candidateNode.size(); ++j)
		{
			int binId = candidateNode[j].y / binSize;
			for (int k = candidateNode[j].y; k < candidateNode[j].y + candidateNode[j].height; ++k)
			{
				availableNode[binId][k%binSize] = 1;
			}
			//availableNode[binId] += candidateNode[j].height;
		}
		if (DEBUG == true)
		{
			for(int j = 0; j < numBin; ++j)
			{
				for(int k = 0; k < binSize; ++k)
				{
					printf("\tavailableNode: %d\n", availableNode[j][k]);
				}
			}printf("\n");
		}

		// calculate the maximum of availableVMNode
		int availableVMNode[NUM_TYPE_VM];
		memset(availableVMNode, 0, sizeof(availableVMNode));
		int sizeVMType[NUM_TYPE_VM] = {S_VM, M_VM, L_VM};
		for(int j = 0; j < NUM_TYPE_VM; ++j)
		{
			for(int k = 0; k < numBin; ++k)
			{
				int num_available_slot = 0;
				for(int l = 0; l < binSize; ++l)
				{
					//availableVMNode[j] += availableNode[k][l];
					num_available_slot += availableNode[k][l];
				}
				availableVMNode[j] += num_available_slot / sizeVMType[j];
			}

		}

		if (DEBUG == true)
		{
			for(int j = 0; j < NUM_TYPE_VM; ++j)
			{
				printf("\tavailableVMNode: %d\n", availableVMNode[j]);
			}printf("\n");
		}

		// calculate the maximum of totalAvailableVMNode
		int totalAvailableVMNode[NUM_TYPE_VM];
		for(int j = 0; j < NUM_TYPE_VM; ++j)
		{
			totalAvailableVMNode[j] = int(binSize / sizeVMType[j]) * numBin;
		}

		// calculate the minimum of availableVMNode
		int availableVMNode_min[NUM_TYPE_VM];
		memset(availableVMNode_min, 0, sizeof(availableVMNode_min));
		for(int j = 0; j < NUM_TYPE_VM; ++j)
		{
			/*if (isOptimized)    // phase 2
			{
				availableVMNode_min[j] = 1;
			}
			else                // phase 1
			{
				availableVMNode_min[j] = min_node % int(totalAvailableVMNode[j] / 2) + 1;
			}
				//availableVMNode_min[j] = int(binSize / sizeVMType[j]) * numBin;*/
			availableVMNode_min[j] = min_node;
		}


		availableVMNode[0] = 0;
		availableVMNode[1] = 0;
		totalAvailableVMNode[0] = 0;
		totalAvailableVMNode[1] = 0;

		for(int j = 0; j < NUM_TYPE_VM; ++j)
		{
			if (availableVMNode_min[j] > availableVMNode[j])
			{
				availableVMNode[j] = 0;
			}
			if (availableVMNode_min[j] > totalAvailableVMNode[j])
			{
				totalAvailableVMNode[j] = 0;
			}
		}

		// do optimization
		JobInfo jobinfo;
		if (isOptimized)	// phase 2
		{
			int sum = 0;
			for(int j = 0; j < NUM_TYPE_VM; ++j)
			{
				sum += availableVMNode[j];
			}
			if (sum == 0)
			{
				continue;
			}

			jobinfo = op_function(app, input_file, boundR - boundL, availableVMNode_min, availableVMNode);
		}
		else				// phase 1
		{
			int sum = 0;
			for(int j = 0; j < NUM_TYPE_VM; ++j)
			{
				sum += totalAvailableVMNode[j];
			}
			if (sum == 0)
			{
				continue;
			}
			jobinfo = op_function(app, input_file, width, availableVMNode_min, totalAvailableVMNode);
		}
		int VMsize = jobinfo.VMsize;
		int VMtype = jobinfo.VMtype;
		int time = jobinfo.time;

		/*if (DEBUG == true)
		{
			VMsize = height;
			VMtype = 2;
			time = width;
		}*/
		if (DEBUG == true)
		{
			printf("\tJobInfo: VMsize(%d), VMtype(%d), time(%d)\n", VMsize, VMtype, time);
		}
	
		for(size_t j = 0; j < candidateNode.size(); ++j)
		{
			for(size_t k = j+1; k < candidateNode.size(); ++k)
			{
				if (IsContainedIn(candidateNode[j], candidateNode[k]))
				{
					candidateNode.erase(candidateNode.begin()+j);
					--j;
					break;
				}
				if (IsContainedIn(candidateNode[k], candidateNode[j]))
				{
					candidateNode.erase(candidateNode.begin()+k);
					--k;
				}
			}
		}

		// if found, try to deploy VM on available nodes
		bool isfound = false;
		finalNode.clear();
		//printf("boundR - boundL: %d\n", boundR - boundL);
		//printf("time: %d\n", time);
		//printf("availableVMNode[VMtype]: %d\n", availableVMNode[VMtype]);
		//printf("VMsize: %d\n", VMsize);
		if (boundR - boundL >= time && availableVMNode[VMtype] >= VMsize)
		{
			int remainH = VMsize * sizeVMType[VMtype];
			//printf("remainH: %d\n", remainH);
			for(size_t j = 0; j < candidateNode.size(); ++j)
			{
				//printf("candidateNode[j].height: %d\n", candidateNode[j].height);
				if(candidateNode[j].height >= sizeVMType[VMtype])
				{
					Rect tmpNode;
					tmpNode.x = candidateNode[j].x;
					tmpNode.y = candidateNode[j].y;
					tmpNode.width = time;
					tmpNode.height = remainH > candidateNode[j].height ? floor(candidateNode[j].height / sizeVMType[VMtype]) * sizeVMType[VMtype]: remainH;

					remainH -= tmpNode.height;
					finalNode.push_back(tmpNode);

					//printf("remainH: %d\n", remainH);
					//printf("tmpNode.height: %d\n", tmpNode.height);
					if (remainH == 0)
					{
						isfound = true;
						break;
					}
				}
			}
			if (isfound == true)
			{
				break;
			}
		}

		// Try to place the rectangle in upright (non-flipped) orientation.
		/*if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
		{
			int topSideX = freeRectangles[i].x + width;
			if (topSideX < bestX || (topSideX == bestX && freeRectangles[i].y < bestY))
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = width;
				bestNode.height = height;
				bestX = topSideX;
				bestY = freeRectangles[i].y;
			}
		}*/
		/*if (binAllowFlip && freeRectangles[i].width >= height && freeRectangles[i].height >= width)
		{
			int topSideY = freeRectangles[i].y + width;
			if (topSideY < bestY || (topSideY == bestY && freeRectangles[i].x < bestX))
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = height;
				bestNode.height = width;
				bestY = topSideY;
				bestX = freeRectangles[i].x;
			}
		}*/
		if (DEBUG == true)
		{
			printf("-------------------------------\n");
		}
	}
	if (DEBUG == true)
	{
		for(size_t j = 0; j < finalNode.size(); ++j)
		{
			printf("\tfinalNode: %d %d %d %d\n", finalNode[j].x, finalNode[j].y, finalNode[j].width, finalNode[j].height);
		}printf("\n");
		printf("-------------------------------\n");
	}
	
	return finalNode;
}

/*std::vector<Rect> MaxRectsBinPack::FindPositionForNewNodeBestShortSideFit(int width, int height, 
	int &bestShortSideFit, int &bestLongSideFit) const
{
	std::vector<Rect> finalNode;
	finalNode.clear();
	Rect bestNode;
	memset(&bestNode, 0, sizeof(Rect));

	bestShortSideFit = std::numeric_limits<int>::max();
	bestLongSideFit = std::numeric_limits<int>::max();

	printf("\n");
	for(size_t i = 0; i < freeRectangles.size(); ++i)
	{
		printf("\tfree rec (%d, %d) (%d, %d)\n", freeRectangles[i].x, freeRectangles[i].y, freeRectangles[i].width, freeRectangles[i].height);
		// Try to place the rectangle in upright (non-flipped) orientation.
		if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
		{
			int leftoverHoriz = abs(freeRectangles[i].width - width);
			int leftoverVert = abs(freeRectangles[i].height - height);
			int shortSideFit = min(leftoverHoriz, leftoverVert);
			int longSideFit = max(leftoverHoriz, leftoverVert);

			if (shortSideFit < bestShortSideFit || (shortSideFit == bestShortSideFit && longSideFit < bestLongSideFit))
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = width;
				bestNode.height = height;
				bestShortSideFit = shortSideFit;
				bestLongSideFit = longSideFit;
			}
		}

		if (binAllowFlip && freeRectangles[i].width >= height && freeRectangles[i].height >= width)
		{
			int flippedLeftoverHoriz = abs(freeRectangles[i].width - height);
			int flippedLeftoverVert = abs(freeRectangles[i].height - width);
			int flippedShortSideFit = min(flippedLeftoverHoriz, flippedLeftoverVert);
			int flippedLongSideFit = max(flippedLeftoverHoriz, flippedLeftoverVert);

			if (flippedShortSideFit < bestShortSideFit || (flippedShortSideFit == bestShortSideFit && flippedLongSideFit < bestLongSideFit))
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = height;
				bestNode.height = width;
				bestShortSideFit = flippedShortSideFit;
				bestLongSideFit = flippedLongSideFit;
			}
		}
	}

	finalNode.push_back(bestNode);
	return finalNode;
}*/

/*Rect MaxRectsBinPack::FindPositionForNewNodeBestLongSideFit(int width, int height, 
	int &bestShortSideFit, int &bestLongSideFit) const
{
	Rect bestNode;
	memset(&bestNode, 0, sizeof(Rect));

	bestShortSideFit = std::numeric_limits<int>::max();
	bestLongSideFit = std::numeric_limits<int>::max();

	for(size_t i = 0; i < freeRectangles.size(); ++i)
	{
		// Try to place the rectangle in upright (non-flipped) orientation.
		if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
		{
			int leftoverHoriz = abs(freeRectangles[i].width - width);
			int leftoverVert = abs(freeRectangles[i].height - height);
			int shortSideFit = min(leftoverHoriz, leftoverVert);
			int longSideFit = max(leftoverHoriz, leftoverVert);

			if (longSideFit < bestLongSideFit || (longSideFit == bestLongSideFit && shortSideFit < bestShortSideFit))
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = width;
				bestNode.height = height;
				bestShortSideFit = shortSideFit;
				bestLongSideFit = longSideFit;
			}
		}

		if (binAllowFlip && freeRectangles[i].width >= height && freeRectangles[i].height >= width)
		{
			int leftoverHoriz = abs(freeRectangles[i].width - height);
			int leftoverVert = abs(freeRectangles[i].height - width);
			int shortSideFit = min(leftoverHoriz, leftoverVert);
			int longSideFit = max(leftoverHoriz, leftoverVert);

			if (longSideFit < bestLongSideFit || (longSideFit == bestLongSideFit && shortSideFit < bestShortSideFit))
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = height;
				bestNode.height = width;
				bestShortSideFit = shortSideFit;
				bestLongSideFit = longSideFit;
			}
		}
	}
	return bestNode;
}*/

/*Rect MaxRectsBinPack::FindPositionForNewNodeBestAreaFit(int width, int height, 
	int &bestAreaFit, int &bestShortSideFit) const
{
	Rect bestNode;
	memset(&bestNode, 0, sizeof(Rect));

	bestAreaFit = std::numeric_limits<int>::max();
	bestShortSideFit = std::numeric_limits<int>::max();

	for(size_t i = 0; i < freeRectangles.size(); ++i)
	{
		int areaFit = freeRectangles[i].width * freeRectangles[i].height - width * height;

		// Try to place the rectangle in upright (non-flipped) orientation.
		if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
		{
			int leftoverHoriz = abs(freeRectangles[i].width - width);
			int leftoverVert = abs(freeRectangles[i].height - height);
			int shortSideFit = min(leftoverHoriz, leftoverVert);

			if (areaFit < bestAreaFit || (areaFit == bestAreaFit && shortSideFit < bestShortSideFit))
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = width;
				bestNode.height = height;
				bestShortSideFit = shortSideFit;
				bestAreaFit = areaFit;
			}
		}

		if (binAllowFlip && freeRectangles[i].width >= height && freeRectangles[i].height >= width)
		{
			int leftoverHoriz = abs(freeRectangles[i].width - height);
			int leftoverVert = abs(freeRectangles[i].height - width);
			int shortSideFit = min(leftoverHoriz, leftoverVert);

			if (areaFit < bestAreaFit || (areaFit == bestAreaFit && shortSideFit < bestShortSideFit))
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = height;
				bestNode.height = width;
				bestShortSideFit = shortSideFit;
				bestAreaFit = areaFit;
			}
		}
	}
	return bestNode;
}*/

/// Returns 0 if the two intervals i1 and i2 are disjoint, or the length of their overlap otherwise.
/*int CommonIntervalLength(int i1start, int i1end, int i2start, int i2end)
{
	if (i1end < i2start || i2end < i1start)
		return 0;
	return min(i1end, i2end) - max(i1start, i2start);
}

int MaxRectsBinPack::ContactPointScoreNode(int x, int y, int width, int height) const
{
	int score = 0;

	if (x == 0 || x + width == binWidth)
		score += height;
	if (y == 0 || y + height == binHeight)
		score += width;

	for(size_t i = 0; i < usedRectangles.size(); ++i)
	{
		if (usedRectangles[i].x == x + width || usedRectangles[i].x + usedRectangles[i].width == x)
			score += CommonIntervalLength(usedRectangles[i].y, usedRectangles[i].y + usedRectangles[i].height, y, y + height);
		if (usedRectangles[i].y == y + height || usedRectangles[i].y + usedRectangles[i].height == y)
			score += CommonIntervalLength(usedRectangles[i].x, usedRectangles[i].x + usedRectangles[i].width, x, x + width);
	}
	return score;
}

Rect MaxRectsBinPack::FindPositionForNewNodeContactPoint(int width, int height, int &bestContactScore) const
{
	Rect bestNode;
	memset(&bestNode, 0, sizeof(Rect));

	bestContactScore = -1;

	for(size_t i = 0; i < freeRectangles.size(); ++i)
	{
		// Try to place the rectangle in upright (non-flipped) orientation.
		if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
		{
			int score = ContactPointScoreNode(freeRectangles[i].x, freeRectangles[i].y, width, height);
			if (score > bestContactScore)
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = width;
				bestNode.height = height;
				bestContactScore = score;
			}
		}
		if (freeRectangles[i].width >= height && freeRectangles[i].height >= width)
		{
			int score = ContactPointScoreNode(freeRectangles[i].x, freeRectangles[i].y, height, width);
			if (score > bestContactScore)
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = height;
				bestNode.height = width;
				bestContactScore = score;
			}
		}
	}
	return bestNode;
}*/

bool MaxRectsBinPack::SplitFreeNode(Rect freeNode, const Rect &usedNode)
{
	// Test with SAT if the rectangles even intersect.
	if (usedNode.x >= freeNode.x + freeNode.width || usedNode.x + usedNode.width <= freeNode.x ||
		usedNode.y >= freeNode.y + freeNode.height || usedNode.y + usedNode.height <= freeNode.y)
		return false;

	if (usedNode.x < freeNode.x + freeNode.width && usedNode.x + usedNode.width > freeNode.x)
	{
		// New node at the top side of the used node.
		if (usedNode.y > freeNode.y && usedNode.y < freeNode.y + freeNode.height)
		{
			Rect newNode = freeNode;
			newNode.height = usedNode.y - newNode.y;
			freeRectangles.push_back(newNode);
		}

		// New node at the bottom side of the used node.
		if (usedNode.y + usedNode.height < freeNode.y + freeNode.height)
		{
			Rect newNode = freeNode;
			newNode.y = usedNode.y + usedNode.height;
			newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height);
			freeRectangles.push_back(newNode);
		}
	}

	if (usedNode.y < freeNode.y + freeNode.height && usedNode.y + usedNode.height > freeNode.y)
	{
		// New node at the left side of the used node.
		if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width)
		{
			Rect newNode = freeNode;
			newNode.width = usedNode.x - newNode.x;
			freeRectangles.push_back(newNode);
		}

		// New node at the right side of the used node.
		if (usedNode.x + usedNode.width < freeNode.x + freeNode.width)
		{
			Rect newNode = freeNode;
			newNode.x = usedNode.x + usedNode.width;
			newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width);
			freeRectangles.push_back(newNode);
		}
	}

	return true;
}

void MaxRectsBinPack::PruneFreeList()
{
	/* 
	///  Would be nice to do something like this, to avoid a Theta(n^2) loop through each pair.
	///  But unfortunately it doesn't quite cut it, since we also want to detect containment. 
	///  Perhaps there's another way to do this faster than Theta(n^2).

	if (freeRectangles.size() > 0)
		clb::sort::QuickSort(&freeRectangles[0], freeRectangles.size(), NodeSortCmp);

	for(size_t i = 0; i < freeRectangles.size()-1; ++i)
		if (freeRectangles[i].x == freeRectangles[i+1].x &&
		    freeRectangles[i].y == freeRectangles[i+1].y &&
		    freeRectangles[i].width == freeRectangles[i+1].width &&
		    freeRectangles[i].height == freeRectangles[i+1].height)
		{
			freeRectangles.erase(freeRectangles.begin() + i);
			--i;
		}
	*/

	/// Go through each pair and remove any rectangle that is redundant.
	for(size_t i = 0; i < freeRectangles.size(); ++i)
		for(size_t j = i+1; j < freeRectangles.size(); ++j)
		{
			if (IsContainedIn(freeRectangles[i], freeRectangles[j]))
			{
				freeRectangles.erase(freeRectangles.begin()+i);
				--i;
				break;
			}
			if (IsContainedIn(freeRectangles[j], freeRectangles[i]))
			{
				freeRectangles.erase(freeRectangles.begin()+j);
				--j;
			}
		}

	// sort freeRectangles by x and then y
	std::sort(freeRectangles.begin(), freeRectangles.end(),
		[] (Rect const& lhs, Rect const& rhs) {return lhs.x != rhs.x ? lhs.x < rhs.x : lhs.y < rhs.y;});
}

}
