function varargout = GUI_ROBANI(varargin)
% GUI_ROBANI MATLAB code for GUI_ROBANI.fig
%      GUI_ROBANI, by itself, creates a new GUI_ROBANI or raises the existing
%      singleton*.
%
%      H = GUI_ROBANI returns the handle to a new GUI_ROBANI or the handle to
%      the existing singleton*.
%
%      GUI_ROBANI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ROBANI.M with the given input arguments.
%
%      GUI_ROBANI('Property','Value',...) creates a new GUI_ROBANI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_ROBANI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_ROBANI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_ROBANI

% Last Modified by GUIDE v2.5 04-May-2021 21:29:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_ROBANI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_ROBANI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_ROBANI is made visible.
function GUI_ROBANI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_ROBANI (see VARARGIN)

% Choose default command line output for GUI_ROBANI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
movegui(hObject, 'center');
clc
clear
% UIWAIT makes GUI_ROBANI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_ROBANI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
 
reqToolboxes = {'Computer Vision System Toolbox', 'Image Processing Toolbox'};
info = ver;
s=size(info);
 
flg = zeros(size(reqToolboxes));
reqSize = size(reqToolboxes,2);
 
for i=1:s(2)
    for j=1:reqSize
        if( strcmpi(info(1,i).Name,reqToolboxes{1,j}) )
            flg(1,j)=1;
        end
    end
end
ret = prod(flg);
 
if ~ret
    error('detectFaceParts requires: Computer Vision System Toolbox and Image Processing Toolbox. Please install these toolboxes.');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname]=uigetfile('*.*');
if ~isequal(filename,0)
    handles.data1 = imread(fullfile(pathname,filename));
    guidata(hObject,handles);
    axes(handles.axes1)
    cla reset
    imshow(handles.data1);
else
    return
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic
X = handles.data1;
thresholdFace = 1;
thresholdParts = 1;
stdsize = 176;
 
nameDetector = {'LeftEye'; 'RightEye'; 'Mouth'; 'Nose'; };
mins = [[12 18]; [12 18]; [15 25]; [15 18]; ];
 
detector.stdsize = stdsize;
detector.detector = cell(5,1);
for k=1:4
    minSize = int32([stdsize/5 stdsize/5]);
    minSize = [max(minSize(1),mins(k,1)), max(minSize(2),mins(k,2))];
    detector.detector{k} = vision.CascadeObjectDetector(char(nameDetector(k)), 'MergeThreshold', thresholdParts, 'MinSize', minSize);
end
 
detector.detector{5} = vision.CascadeObjectDetector('FrontalFaceCART', 'MergeThreshold', thresholdFace);
 
%%%%%%%%%%%%%%%%%%%%%%% detect face %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detect faces
bbox = step(detector.detector{5}, X);
 
bbsize = size(bbox);
partsNum = zeros(size(bbox,1),1);
 
%%%%%%%%%%%%%%%%%%%%%%% detect parts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stdsize = detector.stdsize;
 
for k=1:4
    if( k == 1 )
        region = [1,int32(stdsize*2/3); 1, int32(stdsize*2/3)];
    elseif( k == 2 )
        region = [int32(stdsize/3),stdsize; 1, int32(stdsize*2/3)];
    elseif( k == 3 )
        region = [1,stdsize; int32(stdsize/3), stdsize];
    elseif( k == 4 )
        region = [int32(stdsize/5),int32(stdsize*4/5); int32(stdsize/3),stdsize];
    else
        region = [1,stdsize;1,stdsize];
    end
     
    bb = zeros(bbsize);
    for i=1:size(bbox,1)
        XX = X(bbox(i,2):bbox(i,2)+bbox(i,4)-1,bbox(i,1):bbox(i,1)+bbox(i,3)-1,:);
        XX = imresize(XX,[stdsize, stdsize]);
        XX = XX(region(2,1):region(2,2),region(1,1):region(1,2),:);
         
        b = step(detector.detector{k},XX);
         
        if( size(b,1) > 0 )
            partsNum(i) = partsNum(i) + 1;
             
            if( k == 1 )
                b = sortrows(b,1);
            elseif( k == 2 )
                b = flipud(sortrows(b,1));
            elseif( k == 3 )
                b = flipud(sortrows(b,2));
            elseif( k == 4 )
                b = flipud(sortrows(b,3));
            end
             
            ratio = double(bbox(i,3)) / double(stdsize);
            b(1,1) = int32( ( b(1,1)-1 + region(1,1)-1 ) * ratio + 0.5 ) + bbox(i,1);
            b(1,2) = int32( ( b(1,2)-1 + region(2,1)-1 ) * ratio + 0.5 ) + bbox(i,2);
            b(1,3) = int32( b(1,3) * ratio + 0.5 );
            b(1,4) = int32( b(1,4) * ratio + 0.5 );
             
            bb(i,:) = b(1,:);
        end
    end
    bbox = [bbox,bb];
end
 
 
%%%%%%%%%%%%%%%%%%%%%%% draw faces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bbox = [bbox,partsNum];
bbox(partsNum<=2,:)=[];
 
face =  bbox(:,1: 4);
axes(handles.axes2)
cla reset
imshow(X);
hold on
 
[m, ~] = size(face);
for j = 1:m
    rectangle('Position',[face(j,1),face(j,2),face(j,3),face(j,4)],'EdgeColor','y','LineWidth',2);
end
hold off
toc
% for k = 1:m
%     imcrop(X,[face(k,1),face(k,2),face(k,3),face(k,4)]);
% end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img = getframe(gca);
[filename2,pathname2] = uiputfile(...
    {'*.bmp','bitmap image (*.bmp)';
    '*.jpg','jpeg image(*.bmp)';
    '*.*','All file(*.*)'},...
    'Save Image');
if ~isequal(filename2,0)
    imwrite(img.cdata,fullfile(pathname2,filename2));
else
    return
end
