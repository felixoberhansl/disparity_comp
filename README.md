# cv_challenge_33
CV Challenge from SS 19

used Basic Block Matching approach for the first try
- http://mccormickml.com/2014/01/10/stereo-vision-tutorial-part-i/

other papers:
- https://www.radioeng.cz/fulltexts/2012/12_01_0070_0078.pdf
- https://arxiv.org/pdf/1902.03471.pdf



## Notes
- following parameters can be varied to get (hopefully) better results: blockSize, disparityRange
- first approach is really slow (especially for large images like the motorcycle)
- doffs is the distance between the 2 cameras, was used in a first approach to set the higher limit for the disparity, but in the terrace example is no diiference along the x-axis
- are we getting only pictures that are moved along the x-axis?
