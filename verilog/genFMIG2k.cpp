#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
using namespace std;

int main()
{
    string filename = "./FMIG2k/FMIG4.txt";
    fstream fout(filename.c_str(), fstream::out);
    srand(time(0));
    int min = -128;
    int max = 127;
    for (int i = 0; i < 100; ++i)
    {
        int minn = 2147483647;
        int idxx;
        for (int j = 3; j >= 0; --j)
        {
            int gen = (rand() % 256 - 128);
            if (gen < minn)
            {
                minn = gen;
                idxx = j;
            }
            fout << gen << " ";
        }
        fout << minn << " " << idxx << endl;
    }
    fout.close();
    ///////////////////////////////////////////////////////
    filename = "./FMIG2k/FMIG16.txt";
    fout.open(filename.c_str());
    for (int i = 0; i < 100; ++i)
    {
        int minn = 2147483647;
        int idxx;
        for (int j = 15; j >= 0; --j)
        {
            int gen = (rand() % 256 - 128);
            if (gen < minn)
            {
                minn = gen;
                idxx = j;
            }
            fout << gen << " ";
        }
        fout << minn << " " << idxx << endl;
    }
    fout.close();
    ///////////////////////////////////////////////////////
    filename = "./FMIG2k/FMIG256.txt";
    fout.open(filename.c_str());
    for (int i = 0; i < 100; ++i)
    {
        int minn = 2147483647;
        int idxx;
        for (int j = 255; j >= 0; --j)
        {
            int gen = (rand() % 256 - 128);
            if (gen < minn)
            {
                minn = gen;
                idxx = j;
            }
            fout << gen << " ";
        }
        fout << minn << " " << idxx << endl;
    }
    fout.close();
}