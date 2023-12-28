
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <iostream>

__global__ void grey_scale(int * img,int * grey_img, int height, int width) {
    int i = blockIdx.y * blockDim.y + threadIdx.y;
    int j = blockIdx.x * blockDim.x + threadIdx.x;

    int index = i * (width * 3) + (j * 3);


    if (i > height) return;
    if (j > width) return;
    grey_img[i * width + j] = ((float)img[index] * 0.21f) + ((float)img[index + 1] * 0.72f) + ((float)img[index + 2] * 0.07f);
}

int main() {

    std::cout << "Hola\n";

    std::ifstream file;
    file.open("C:\\Users\\pc\\Desktop\\8vo Semestre\\Computacion Paralela y Distribuida\\Lab cuda\\grey_scale\\image.txt");
    int width = 10, height = 10;
    file >> height >> width;

    int* img = (int*)malloc(height * width * 3 * sizeof(int));
    int* grey_img = (int*)malloc(height * width * sizeof(int));

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int index = i * (width * 3) + (j * 3);
            file >> img[index] >> img[index + 1] >> img[index + 2];
        }
    }

    file.close();

    dim3 threadsPerBlock(16, 16);

    int bx = std::ceil((float)height / 16.f);
    int by = std::ceil((float)width / 16.f);


    dim3 numBlocks(bx, by);

    int* d_img, * d_grey_img;

    cudaMalloc(&d_img, height * width * 3 * sizeof(int));
    cudaMalloc(&d_grey_img, height * width * sizeof(int));
    
    cudaMemcpy(d_img, img, (height * width * 3) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_grey_img, grey_img, (height * width) * sizeof(int), cudaMemcpyHostToDevice);

    
    grey_scale << <numBlocks, threadsPerBlock >> > (d_img, d_grey_img, height, width);
    
    cudaMemcpy(grey_img, d_grey_img, (height * width) * sizeof(int), cudaMemcpyDeviceToHost);

    
    std::ofstream res;
    res.open("C:\\Users\\pc\\Desktop\\8vo Semestre\\Computacion Paralela y Distribuida\\Lab cuda\\grey_scale\\new_image.txt");


    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            res << grey_img[i * width + j] << '\n';
        }
    }

    res.close();

    //system("python C:\\Users\\pc\\Desktop\\8vo Semestre\\Computacion Paralela y Distribuida\\Lab cuda\\write_image.py");
    
    free(img);
    free(grey_img);

    cudaFree(d_img);
    cudaFree(d_grey_img);

    printf("QUE");

    return 0;
}