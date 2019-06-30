# cv_challenge_33
CV Challenge from SS 19

Overview of research:

Most approaches apply some hybrid method of matching that considers the known geometry (Rotation, Translatation) and a matching 
on image parameters (intensity, entropy, ...)

- ***Depth Discontinuities by Pixel-to-Pixel Stereo*** (Birchfield and Tomasi)

https://users.cs.duke.edu/~tomasi/papers/birchfield/birchfieldTr96.pdf

In a right and a left image so called scan lines are compared to match single pixels. 
Therefore the path with the lowest cost is calculated along the scan line. 
The cost calculation is mainly based on the intensities and a few constraints, that help
to avoid unrealistic matches. 

PRO: easy approach, fast

CON: how to obtain these scan lines, it requires rectified images, right? Not sure, how the
method would work, if a pixel from image A is matched to one pixel of a scan line in B (also computational expensive)


- ***Nonparametric Local Transforms for Computing Visual Correspondence*** (Zabih and Woodfill)

http://www.cs.cornell.edu/~rdz/Papers/ZW-ECCV94.pdf

Pixel matching is done on a CENSUS transformation. For each pixel a binary matrix is constructed, that states, if the
pixels next to the pixel in question have a higher intensity or a lower. 

PRO: simplest approach that yields good results

CON: oldest approach, does not specify additional constraints, that avoid unrealistic matching or post processing methods
(but Hirschmuellers methods could also be applied)


- ***Stereo Processing by Semiglobal Matching and Mutual Information*** (Hirschmueller)

https://elib.dlr.de/73119/1/180Hirschmueller.pdf
http://www.cvlibs.net/projects/autonomous_vision_survey/literature/Hirschmueller2008PAMI.pdf


Uses entropy of image to match pixels

PRO: newest approach (mentions the other 2 and claims to perform slightly better), specifies post processing/constraints that could
also be used on above approaches

CON: seems very complex to implement, requires reading up on other methods




## Notes
