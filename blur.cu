
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <iostream>

#define HEIGHT 64
#define WIDTH 64

__global__ void blur_image(int * img, int * blurred_img, int height, int width) {
    int i = blockIdx.y * blockDim.y + threadIdx.y;
    int j = blockIdx.x * blockDim.x + threadIdx.x;

    if (i > height) return;
    if (j > width) return;
    

    int index = i * (width * 3) + (j * 3);
    blurred_img[index + 0] = 0;
    blurred_img[index + 1] = 0;
    blurred_img[index + 2] = 0;

    int count = 0;
    for (int ii = i - 1; ii < i + 2; ii++)
    {
        if (ii < 0) continue;
        else if (ii >= height) break;
        for (int jj = j - 1; jj < j + 2; jj++)
        {
            if (jj < 0) continue;
            else if (jj >= width) break;
            int ind_n = ii * (width * 3) + (jj * 3);
            blurred_img[index + 0] += img[ind_n + 0];
            blurred_img[index + 1] += img[ind_n + 1];
            blurred_img[index + 2] += img[ind_n + 2];
            count++;
        }
    }

    blurred_img[index + 0] /= count;
    blurred_img[index + 1] /= count;
    blurred_img[index + 2] /= count;
}


int main() {

    std::cout << "Hola\n";
    
    std::ifstream file;
    file.open("C:\\Users\\pc\\Desktop\\8vo Semestre\\Computacion Paralela y Distribuida\\Lab cuda\\image.txt");
    int width= 10, height = 10;
    file >> height >> width;

    int * img = (int*)malloc(height * width * 3 * sizeof(int));
    int * blurred_img = (int*)malloc(height * width * 3 * sizeof(int));
    
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
    
    int* d_img, * d_blurred_img;
    
    cudaMalloc(&d_img, height * width * 3 * sizeof(int));
    cudaMalloc(&d_blurred_img, height * width * 3 * sizeof(int));
    
    cudaMemcpy(d_img, img, (height * width * 3) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_blurred_img, blurred_img, (height * width * 3) * sizeof(int), cudaMemcpyHostToDevice);
    

    blur_image <<<numBlocks,threadsPerBlock>>> (d_img, d_blurred_img, height, width);
    
    cudaMemcpy(blurred_img, d_blurred_img, (height * width * 3) * sizeof(int), cudaMemcpyDeviceToHost);
    

    std::ofstream res;
    res.open("C:\\Users\\pc\\Desktop\\8vo Semestre\\Computacion Paralela y Distribuida\\Lab cuda\\new_image.txt");
    

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            res << blurred_img[i * (width * 3) + (j * 3)] << '\n' << blurred_img[i * (width * 3) + (j * 3) + 1] << '\n' << blurred_img[i * (width * 3) + (j * 3) + 2] << '\n';
        }
    }

    res.close();

    //system("python C:\\Users\\pc\\Desktop\\8vo Semestre\\Computacion Paralela y Distribuida\\Lab cuda\\write_image.py");
   
    free(img);
    free(blurred_img);
   
    cudaFree(d_img);
    cudaFree(d_blurred_img);    

    printf("QUE");
    
    return 0;
}