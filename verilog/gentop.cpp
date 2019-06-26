#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <vector>
#include <iomanip>
using namespace std;

int main()
{
    srand(time(0));
    int min = -128;
    int max = 127;
    vector<int> vec; // all kinds of numbers of input to simulate
    vec.push_back(7);
    vec.push_back(255);
    for (unsigned int k = 0; k < vec.size(); ++k)
    {
        char buffer[5];
        itoa(vec[k], buffer, 10);
        string filename = string("./Top/") + buffer + ".txt";
        cerr << "Generating data of " << vec[k] << " inputs with filename: " << filename << endl;
        fstream fout(filename.c_str(), fstream::out);
        for (int i = 0; i < 100; ++i)
        {
            int minn = 2147483647;
            int minn2 = 2147483647;
            int idxx;
            for (int j = vec[k] - 1; j >= 0; --j)
            {
                int gen = (rand() % 256 - 128);
                if (gen < minn)
                {
                    minn2 = minn;
                    minn = gen;
                    idxx = j;
                }
                else if (gen < minn2)
                {
                    minn2 = gen;
                }
                fout << setw(4) << gen << " ";
            }
            fout << setw(4) << minn << " " << setw(4) << minn2 << " " << setw(4) << idxx << endl;
        }
        fout.close();
    }
    return 0;
}