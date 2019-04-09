clc;
clear all;

%get image file and output file names from the user
in_img='input image file (with file extension type): ';
img_file=input(in_img,'s');
out_img='input image file (with file extension type): ';
out_file=input(out_img,'s');

%read image
img=imread(img_file);
%take one color plane
plane1=img(:,:,1)';

%convert color plane vector to binary
bin_data=de2bi(plane1,'left-msb');
k=char(bin_data + 48);

%write binary image vector to .coe file
file=fopen(out_file,'w');
fprintf(file,'MEMORY_INITIALIZATION_RADIX=2;\nMEMORY_INITIALIZATION_VECTOR=\n');
for i=1:65536
   t=k(i,:);
   fprintf(file,t);
   fprintf(file,',');
   fprintf(file,'\n');
end

fclose(file);
fprintf('***************************************************');
fprintf('image converted to binary .coe format successfully !');
