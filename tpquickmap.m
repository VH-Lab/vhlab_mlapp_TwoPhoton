function [im]  = tpquickmap(dirname,channel,resps,pixels,plotit,method,param1,param2)

%  TPQUICKMAP - Produces a colored map of responses
%  IM=TPQUICKMAP(DIRNAME,CHANNEL,RESPS,PIXELS,PLOTIT,METHOD,PARAM1,PARAM2)
%
%    Generates a color map of neural responses.
%
%  DIRNAME is the name of the directory.  A preview image, based on
%  the first 50 frames, is generated from this data.
%
%  CHANNEL is the channel number to be read.
%
%  RESPS is the responses, as output from TPTUNINGCURVE.
%
%  PIXELS is a cell list of pixel indices from the image.
%
%  If PLOTIT is 1 data are plotted in a new window.
%
%  METHOD specifies the mapping method.  Can be
%  'threshold' Peaks above threshold specified in PARAM1 are good
%  (more to be added)


im1 = tppreview(dirname,50,1,channel);
im1 = rescale(im1,[min(min(im1)) max(max(im1))],[0 1]);
im2 = im1; im3 = im1;

numcolors = length(resps(1).curve(1,:));
ctab = jet(numcolors);

for i=1:length(resps),
	if strcmp(method,'threshold'),
		[m,pki] = max(resps(i).curve(2,:));
		pki = pki(1); m = m(1);
		if m>param1,
			im1(pixels{i}) = ctab(pki,1);
			im2(pixels{i}) = ctab(pki,2);
			im3(pixels{i}) = ctab(pki,3);
		end;
	end;
end;

im = cat(3,im1,im2,im3);

if 0,
li = linspace(1,numcolors,size(im,1));
im(:,end-10:end,1) = repmat(ctab(round(li),1),1,11);
im(:,end-10:end,2) = repmat(ctab(round(li),2),1,11);
im(:,end-10:end,3) = repmat(ctab(round(li),3),1,11);
end;

if plotit,
	figure;
	image(im);
end;

global myimmap
myimmap = im;
