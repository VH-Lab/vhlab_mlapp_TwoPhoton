function [im,params]= previewprairieview(dirname, numFrames, firstFrames, channel)

%  PREVIEWPRAIRIEVIEW - Preview PrairieView image data
%
%    IM = PREVIEWPRAIRIEVIEW(DIRNAME, NUMFRAMES, FIRSTFRAMES,CHANNEL)
%
%  Read a few frames to create a preview image.  DIRNAME is the
%  directory name to be opened, and NUMFRAMES is the number of
%  frames to read.  If FIRSTFRAMES is 1, then the first NUMFRAMES
%  frames will be read; otherwise, the frames will be taken
%  randomly from those available.
% 
%  CHANNEL is the channel to be read.  If it is empty, then
%  all channels will be read and third dimension of im will
%  correspond to channel.  For example, im(:,:,1) would be
%  preview image from channel 1.
%
%  DIRNAME will have '-001' appended to it.
%

tpdirname = [dirname ];

if ~exist(tpdirname),
	error(['Directory ' tpdirname ' does not exist.']);
end;

pcfile = dir([tpdirname filesep '*_Main.pcf']);
if isempty(pcfile), pcfile = dir([tpdirname filesep '*.xml']); end;
pcfile = pcfile(end).name;
params = readprairieconfig([tpdirname filesep pcfile]);
tpfileparams = tpfnameparams(tpdirname,channel,params);

if isfield(params,'Type'),
	if strcmp(params.Type,'Linescan')|strcmp(params.Type,'linescan'),
		im = double(imread(fullfile(tpdirname,tpfilename_linescansource(tpfileparams,1,channel))));
        im = medfilt2(im,[5 5]);
		return;
	end;
end;

ffile = repmat([0 0],length(params.Image_TimeStamp__us_),1);

initind = 1;
for i=1:params.Main.Total_cycles,
  frames=getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
  ffile(initind:initind+frames-1,:) = [repmat(i,frames,1) (1:frames)'];
  initind = initind + frames;
end;

if firstFrames,
	n = 1:numFrames;
else,
	N = randperm(length(params.Image_TimeStamp__us_));
	n = N(1:numFrames);
end;

im = [];

for i=1:numFrames,
	im = cat(1,im,imread(...
		fullfile(tpdirname,tpfilename(tpfileparams,ffile(i,1),channel,ffile(i,2)))));
end;
if size(im,1)>1, im = mean(double(im)); else, im = double(im); end;
%im = reshape(im,params.Main.Lines_per_frame,params.Main.Pixels_per_line);
