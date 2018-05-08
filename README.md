# thesis2018

These are the jupyter iPython notebook files consisting of all the functional code used for a thesis project on traffic sign detection and recognition.

When you open a .ipynb file, please do not re-run any code block since the important outputs should have been saved in the notebook.  Also, running any code will cause errors because it will try to retrieve data from local paths specfiic to my computer and development environment.

The matlab files can be run, however, through demo.m, which is a modificaiton of the original demo file that came with the packaged code from "https://koen.me/research/selectivesearch/".

Abtract for thesis below:

In this paper we present a novel modification of the r-CNN architecture for the task of traffic sign detection and recognition.  We train and evaluate all models on the German Traffic Sign Detection and Recognition benchmark datasets.  Our approach simplifies original r-CNN components and tailors each layer of a 3-layer pipeline to the task of recognizing traffic signs.  We combine Selective Search region proposal in the first layer, along with either SVM or CNN models for both detection and recognition layers.  We successfully modify the LeNet5 architecture famous for use on grayscale MNIST digit classification to instead detect and classify traffic sign instances.  Our best pipeline configuration yields a recall of 100%, precision of 66%, and false positive rejection rate of 96% on the detection task of this problem. All code for this project is available for download at https://github.com/lanidenis/thesis2018.

