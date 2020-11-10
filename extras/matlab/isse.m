%  Copyright 2013 Adobe Systems Incorporated and Stanford University
%  Distributed under the terms of the Gnu General Public License
%  
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation.
%  
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%  
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 
%  Authors: Nicholas J. Bryan
function varargout = isse(varargin)
% ISSE MATLAB code for isse.fig
%      ISSE, by itself, creates a new ISSE or raises the existing
%      singleton*.
%
%      H = ISSE returns the handle to a new ISSE or the handle to
%      the existing singleton*.
%
%      ISSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ISSE.M with the given input arguments.
%
%      ISSE('Property','Value',...) creates a new ISSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before isse_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to isse_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help isse

% Last Modified by GUIDE v2.5 27-Oct-2013 18:04:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @isse_OpeningFcn, ...
                   'gui_OutputFcn',  @isse_OutputFcn, ...
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


% --- Executes just before isse is made visible.
function isse_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to isse (see VARARGIN)

% Choose default command line output for isse
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(gcf,'commonFs', 16000);
setappdata(gcf,'source0', 0);
setappdata(gcf,'fs', 0);
setappdata(gcf,'source1', 0);
setappdata(gcf,'source2', 0);
setappdata(gcf,'mixtureDirty',0);
setappdata(gcf,'pastpointX',-1);
setappdata(gcf,'pastpointY',-1);

 

 

% separation stuff
contents = cellstr(get(handles.fftsizepopup,'String'));
FFTSIZE = contents{get(handles.fftsizepopup,'Value')};
FFTSIZE = round(str2double(FFTSIZE));
setappdata(gcf,'FFTSIZE', FFTSIZE);

contents = cellstr(get(handles.hopsizepopup,'String'));
HOPSIZE = contents{get(handles.hopsizepopup,'Value')};
HOPSIZE = round(str2double(HOPSIZE));
setappdata(gcf,'HOPSIZE', HOPSIZE);

MAXITERS = get(handles.itersSlider,'Value');
set(handles.itersTxt,'String',num2str(MAXITERS));
setappdata(gcf,'MAXITERS',MAXITERS);


setappdata(gcf,'mixtureRadio',0)

setappdata(gcf,'K1',get(handles.numComps1,'Value'));
setappdata(gcf,'K2',get(handles.numComps2,'Value'));

% tooltip stuff
setappdata(gcf,'subtract',1)
setappdata(gcf,'tipwidth',get(handles.brushWidth,'Value'));
setappdata(gcf,'tipheight',get(handles.brushHeight,'Value'));
setappdata(gcf,'tipamp',get(handles.brushAmp, 'Value'));
setappdata(gcf, 'selectedsource', 1);


 

setappdata(gcf,'selectedplot',1)

setappdata(gcf,'source1Dict',[]);
setappdata(gcf,'source2Dict',[]);
setappdata(gcf,'totalActivations',[]);
setappdata(gcf,'source1Supervised',0);
setappdata(gcf,'source2Supervised',0);

% clear axes of tic marks
axes(handles.mixturePlot) 
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
axes(handles.source1plot) 
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
axes(handles.source2plot) 
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);

 
evalin('base','clear all');

% --- Outputs from this function are returned to the command line.
function varargout = isse_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

 

% --- Executes on key release with focus on figure1 and none of its controls.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Key,'shift')
    setappdata(gcf,'pastpointX', -1);
    setappdata(gcf,'pastpointY', -1);
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

if get(hObject,'Value')
    setappdata(gcf,'subtract',-1)
else
    setappdata(gcf,'subtract',1)
end


% --- Executes on slider movement.
function brushWidth_Callback(hObject, eventdata, handles)
% hObject    handle to brushWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(hObject,'Value');
setappdata(gcf,'tipwidth',sliderValue);

% --- Executes during object creation, after setting all properties.
function brushWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brushWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function brushAmp_Callback(hObject, eventdata, handles)
% hObject    handle to brushAmp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(hObject,'Value');
setappdata(gcf,'tipamp',sliderValue);

% --- Executes during object creation, after setting all properties.
function brushAmp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brushAmp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function brushHeight_Callback(hObject, eventdata, handles)
% hObject    handle to brushHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(hObject,'Value');
setappdata(gcf,'tipheight',sliderValue);

% setappdata(gcf,'tipheight',10);

% --- Executes during object creation, after setting all properties.
function brushHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brushHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function Xdb = plotSpectrogram1( reset )

    global MASK1TFa
    global MASK1TFb
    x = getappdata(gcf,'source0');
    fs = getappdata(gcf,'fs');
    FFTSIZE = getappdata(gcf,'FFTSIZE');
    HOPSIZE = getappdata(gcf,'HOPSIZE');
    hold off;
    dbdown = 70;
    [h, Xdb] = plotspec(x, fs, FFTSIZE, HOPSIZE, dbdown);
    
    setappdata(gcf, 'handle1a',h);
    hold on;
    nframes = size(Xdb,2);
    t = (0:nframes-1)*HOPSIZE/fs;
    f = 0.001*(0:FFTSIZE-1)*(fs/2)/FFTSIZE;

    if reset
        
        green = cat(3, zeros(size(Xdb)), ones(size(Xdb)), zeros(size(Xdb)));
        red = cat(3, ones(size(Xdb)), zeros(size(Xdb)), zeros(size(Xdb)));
        setappdata(gcf, 'greenimage', green);
        setappdata(gcf, 'redimage', red);
        
        % reinitialize mask data
        MASK1TFa = zeros(size(Xdb)); 
        MASK1TFb = zeros(size(Xdb)); 
    end
    
 
        h = image(t,f,getappdata(gcf, 'greenimage'));
        set(h, 'AlphaData', MASK1TFa);
        setappdata(gcf, 'handle1a',h);
        
        red = getappdata(gcf, 'redimage');
        h = image(t,f,red);
        set(h, 'AlphaData', MASK1TFb);
        setappdata(gcf, 'handle1b',h);
 

function Xdb = plotSpectrogram2( reset )

 
    global MASK2TFa
    global MASK2TFb
    x = getappdata(gcf,'source1');
    fs = getappdata(gcf,'fs');
    FFTSIZE = getappdata(gcf,'FFTSIZE');
    HOPSIZE = getappdata(gcf,'HOPSIZE');
    hold off;
    dbdown = 70;
    [h, Xdb] = plotspec(x, fs, FFTSIZE, HOPSIZE, dbdown);
    
    setappdata(gcf, 'handle2a',h);
    hold on;
    nframes = size(Xdb,2);
    t = (0:nframes-1)*HOPSIZE/fs;
    f = 0.001*(0:FFTSIZE-1)*(fs/2)/FFTSIZE;

    if reset
        
        green = cat(3, zeros(size(Xdb)), ones(size(Xdb)), zeros(size(Xdb)));
        red = cat(3, ones(size(Xdb)), zeros(size(Xdb)), zeros(size(Xdb)));
        setappdata(gcf, 'greenimage', green);
        setappdata(gcf, 'redimage', red);
        
        % reinitialize mask data
        MASK2TFa = zeros(size(Xdb)); 
        MASK2TFb = zeros(size(Xdb)); 
    end
    
 
    h = image(t,f,getappdata(gcf, 'greenimage'));
    set(h, 'AlphaData', MASK2TFa);
    setappdata(gcf, 'handle2a',h);
        
    red = getappdata(gcf, 'redimage');
    h = image(t,f,red);
    set(h, 'AlphaData', MASK2TFb);
    setappdata(gcf, 'handle2b',h);
   
function Xdb = plotSpectrogram3( reset )    
 
    global MASK3TFa
    global MASK3TFb
    x = getappdata(gcf,'source2');
    fs = getappdata(gcf,'fs');
    FFTSIZE = getappdata(gcf,'FFTSIZE');
    HOPSIZE = getappdata(gcf,'HOPSIZE');
    hold off;
    dbdown = 70;
    [h, Xdb] = plotspec(x, fs, FFTSIZE, HOPSIZE, dbdown);
    
    setappdata(gcf, 'handle3a',h);
    hold on;
    nframes = size(Xdb,2);
    t = (0:nframes-1)*HOPSIZE/fs;
    f = 0.001*(0:FFTSIZE-1)*(fs/2)/FFTSIZE;

    if reset
        green = cat(3, zeros(size(Xdb)), ones(size(Xdb)), zeros(size(Xdb)));
        red = cat(3, ones(size(Xdb)), zeros(size(Xdb)), zeros(size(Xdb)));
        setappdata(gcf, 'greenimage', green);
        setappdata(gcf, 'redimage', red);
        
        % reinitialize mask data
        MASK3TFa = zeros(size(Xdb)); 
        MASK3TFb = zeros(size(Xdb)); 
    end
    
 
    h = image(t,f,getappdata(gcf, 'greenimage'));
    set(h, 'AlphaData', MASK3TFa);
    setappdata(gcf, 'handle3a',h);
        
    red = getappdata(gcf, 'redimage');
    h = image(t,f,red);
    set(h, 'AlphaData', MASK3TFb);
    setappdata(gcf, 'handle3b',h);
  
% --------------------------------------------------------------------
function export_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FILTERSPEC = '*.wav';
[FILENAME, PATHNAME, FILTERINDEX] = uiputfile(FILTERSPEC, 'Export Audio As...');

if FILENAME==0
    return
end

FILENAME = [PATHNAME FILENAME];

source1 = getappdata(gcf,'source1');
source2 = getappdata(gcf,'source2');
fs = getappdata(gcf,'fs');
wavwrite(source1, fs, 16, [FILENAME(1:(end-4)) '-1']);
wavwrite(source2, fs, 16, [FILENAME(1:(end-4)) '-2']);


% --------------------------------------------------------------------
function openbutton_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to openbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FILTERSPEC = '*.iss';
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile(FILTERSPEC, 'Open File...');

if FILENAME==0
    return
end
 
global MASK1TFa;
global MASK1TFb;
global MASK2TFa;
global MASK2TFb;
global MASK3TFa;
global MASK3TFb;

FILENAME = [PATHNAME FILENAME];

fs = load(FILENAME, '-mat', 'fs')
mixture = load(FILENAME, '-mat', 'source0');

source1 = load(FILENAME, '-mat', 'source1');
source2 = load(FILENAME, '-mat', 'source2');
FFTSIZE = load(FILENAME, '-mat', 'FFTSIZE');
HOPSIZE = load(FILENAME, '-mat', 'HOPSIZE');
K1 = load(FILENAME, '-mat', 'K1');
K2 = load(FILENAME, '-mat', 'K2');

MASK1TFat = load(FILENAME, '-mat', 'MASK1TFa')
MASK1TFbt = load(FILENAME, '-mat', 'MASK1TFb')
MASK2TFat = load(FILENAME, '-mat', 'MASK2TFa')
MASK2TFbt = load(FILENAME, '-mat', 'MASK2TFb')
MASK3TFat = load(FILENAME, '-mat', 'MASK3TFa')
MASK3TFbt = load(FILENAME, '-mat', 'MASK3TFb')
 

MASK1TFb = MASK1TFbt.MASK1TFb;
MASK1TFa = MASK1TFat.MASK1TFa;

MASK2TFb = MASK2TFbt.MASK2TFb;
MASK2TFa = MASK2TFat.MASK2TFa;

MASK3TFb = MASK3TFbt.MASK3TFb;
MASK3TFa = MASK3TFat.MASK3TFa;

green = cat(3, zeros(size(MASK3TF)), ones(size(MASK3TF)), zeros(size(MASK3TF)));
setappdata(gcf, 'greenimage', green);

   
% update internal storage
setappdata(gcf,'source0', mixture.mixture);
setappdata(gcf,'source1', source1.source1);
setappdata(gcf,'source2', source2.source2);
setappdata(gcf,'FFTSIZE',round(FFTSIZE.FFTSIZE));
setappdata(gcf,'HOPSIZE',round(HOPSIZE.HOPSIZE));
setappdata(gcf,'K1', round(K1.K1));
setappdata(gcf,'K2', round(K2.K2));
setappdata(gcf,'fs',fs.fs);
 


% plot 1
axes(handles.mixturePlot) 
plotSpectrogram1(0);

axes(handles.source1plot) 
plotSpectrogram2(0);

axes(handles.source2plot) 
plotSpectrogram3(0);

% create and set audio players for each sound
createAudioPlayers(0, handles);

set(handles.numComps1,'Value', getappdata(gcf,'K1'))
set(handles.numComps2,'Value', getappdata(gcf,'K2'))

set(handles.numComps1Txt,'String', num2str(getappdata(gcf,'K1')))
set(handles.numComps2Txt,'String', num2str(getappdata(gcf,'K2')))
 
 

 

%set: FFT and HOP handles
contents = cellstr(get(handles.fftsizepopup,'String'));
for i=1:size(contents,1)
    if round(str2double(contents{i}))==round(FFTSIZE.FFTSIZE)
       set(handles.fftsizepopup,'Value',i);
    end
end

contents = cellstr(get(handles.hopsizepopup,'String'));
for i=1:size(contents,1)
    if round(str2double(contents{i}))==round(HOPSIZE.HOPSIZE)
       set(handles.hopsizepopup,'Value',i);
    end
end
 
% --------------------------------------------------------------------
function savebutton_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FILTERSPEC = '*.iss';
[FILENAME, PATHNAME, FILTERINDEX] = uiputfile(FILTERSPEC, 'Save File As...');

if FILENAME==0
    return
end

global MASK1TFa;
global MASK1TFb;
global MASK2TFa;
global MASK2TFb;
global MASK3TFa;
global MASK3TFb;

FILENAME = [PATHNAME FILENAME];
save(FILENAME,'');

% what to save
mixture = getappdata(gcf,'source0');
source1 = getappdata(gcf,'source1');
source2 = getappdata(gcf,'source2');
FFTSIZE = getappdata(gcf,'FFTSIZE');
HOPSIZE = getappdata(gcf,'HOPSIZE');
K1 = getappdata(gcf,'K1');
K2 = getappdata(gcf,'K2');
fs = getappdata(gcf,'fs');
 

save(FILENAME,'fs','-append');
save(FILENAME,'source0','-append');
save(FILENAME,'source1','-append');
save(FILENAME,'source2','-append');
save(FILENAME,'FFTSIZE','-append');
save(FILENAME,'HOPSIZE','-append');
save(FILENAME,'K1','-append');
save(FILENAME,'K2','-append');

save(FILENAME,'MASK1TFa','-append');
save(FILENAME,'MASK1TFb','-append');
save(FILENAME,'MASK2TFa','-append');
save(FILENAME,'MASK2TFb','-append');
save(FILENAME,'MASK3TFa','-append');
save(FILENAME,'MASK3TFb','-append');
 


function figure1_WindowButtonUpFcn(hObject, eventdata, handles)


setappdata(gcf,'buttondown',0)
 
 


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(gcf,'buttondown',1)
currentAxes = gca;

if currentAxes==handles.mixturePlot
    setappdata(gcf,'selectedplot',1)
elseif currentAxes==handles.source1plot
    setappdata(gcf,'selectedplot',2)
elseif currentAxes==handles.source2plot
    setappdata(gcf,'selectedplot',3)
else
    setappdata(gcf,'selectedplot',0)
end

% --- Executes on button press in clearMixture.
function clearMixture_Callback(hObject, eventdata, handles)
% hObject    handle to clearMixture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global MASK1TFa
global MASK1TFb

fs = getappdata(gcf,'fs');
MASK1TFa = MASK1TFa*0;  
MASK1TFb = MASK1TFb*0; 

h = getappdata(gcf, 'handle1Overlay');

if ~isempty(h)    
    refreshdata(h);
end

h = getappdata(gcf, 'handle1a');
try
	set(h, 'AlphaData', MASK1TFa);
catch ME
end
h = getappdata(gcf, 'handle1b');
try
	set(h, 'AlphaData', MASK1TFb);
catch ME
end


% --- Executes on button press in clearSource1.
function clearSource1_Callback(hObject, eventdata, handles)
% hObject    handle to clearSource1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 
global MASK2TFa
global MASK2TFb

fs = getappdata(gcf,'fs');
MASK2TFa = MASK2TFa*0;  
MASK2TFb = MASK2TFb*0; 

h = getappdata(gcf, 'handle2Overlay');

if ~isempty(h)    
    refreshdata(h);
end

h = getappdata(gcf, 'handle2a');
try
	set(h, 'AlphaData', MASK2TFa);
catch ME
end
h = getappdata(gcf, 'handle2b');
try
	set(h, 'AlphaData', MASK2TFb);
catch ME
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over clearSource1.
function clearSource1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to clearSource1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in clearSource2.
function clearSource2_Callback(hObject, eventdata, handles)
% hObject    handle to clearSource2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global MASK3TFa
global MASK3TFb

fs = getappdata(gcf,'fs');
MASK3TFa = MASK3TFa*0;  
MASK3TFb = MASK3TFb*0; 

h = getappdata(gcf, 'handle3Overlay');

if ~isempty(h)    
    refreshdata(h);
end

h = getappdata(gcf, 'handle3a');
try
	set(h, 'AlphaData', MASK3TFa);
catch ME
end
h = getappdata(gcf, 'handle3b');
try
	set(h, 'AlphaData', MASK3TFb);
catch ME
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over clearSource2.
function clearSource2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to clearSource2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % make sure there's a selected plot
    selectedPlot = getappdata(gcf,'selectedplot');
    if isempty(selectedPlot)
        return
    end
     
    global MASK1TFa
    global MASK1TFb
    global MASK2TFa
    global MASK2TFb
    global MASK3TFa
    global MASK3TFb
    
    selectedPlot = getappdata(gcf,'selectedplot');
    
    mask1a = 0;
    if getappdata(gcf, 'selectedsource')==2
        mask1a = 1;
    end
    
        if getappdata(gcf,'buttondown')~=1
        return
    end
    

 
    if selectedPlot==1
        if mask1a
            h = getappdata(gcf, 'handle1a');
        else
            h = getappdata(gcf, 'handle1b');
        end
    elseif selectedPlot==2
        if mask1a
            h = getappdata(gcf, 'handle2a');
        else
            h = getappdata(gcf, 'handle2b');
        end
    elseif selectedPlot==3
        if mask1a
            h = getappdata(gcf, 'handle3a');
        else
            h = getappdata(gcf, 'handle3b');
        end
    else
        return
    end
    
    subtract = getappdata(gcf,'subtract');
    sigma2x = 10*getappdata(gcf,'tipwidth');
    sigma2y = 10*getappdata(gcf,'tipheight');
    A = subtract*getappdata(gcf,'tipamp');
 
    fs = getappdata(gcf,'fs');
    HOPSIZE = getappdata(gcf,'HOPSIZE');
    a = get(gca,'currentpoint');
    x = round( a(1)*fs/HOPSIZE );
    y = size(MASK2TFa,1)*a(1,2)/(fs/2000);
    pf = round([x y]);

    halfwidth = 30;
        
    xmin = (pf(1)-halfwidth);
    xmax = (pf(1)+halfwidth);
        
    ymin = (pf(2)-halfwidth);
    ymax = (pf(2)+halfwidth);
 
    if xmin < 1
        xmin = 1;
    end
    if xmax > size(MASK2TFa,2)
        xmax = size(MASK2TFa,2);
    end
    if ymin < 1
        ymin = 1;
    end
    if ymax > size(MASK2TFa,1)
        ymax = size(MASK2TFa,1);
    end
 
    xgrid = xmin:xmax;
    ygrid = ymin:ymax;
    


    for xind = 1:length(xgrid)
        for yind = 1:length(ygrid)
                
            v = A*exp(-(  ((xgrid(xind) - pf(1)).^2)/(2*sigma2x) + ((ygrid(yind) - pf(2)).^2)/(2*sigma2y)));
            if selectedPlot==1
                if mask1a
                    MASK1TFa(ygrid(yind),xgrid(xind),:) = min(pos(MASK1TFa(ygrid(yind),xgrid(xind),:) + v),1);
                else
                    MASK1TFb(ygrid(yind),xgrid(xind),:) = min(pos(MASK1TFb(ygrid(yind),xgrid(xind),:) + v),1);
                end
            elseif selectedPlot==2
                if mask1a
                    MASK2TFa(ygrid(yind),xgrid(xind),:) = min(pos(MASK2TFa(ygrid(yind),xgrid(xind),:) + v),1);
                else
                    MASK2TFb(ygrid(yind),xgrid(xind),:) = min(pos(MASK2TFb(ygrid(yind),xgrid(xind),:) + v),1);
                end
            elseif selectedPlot==3
                if mask1a
                    MASK3TFa(ygrid(yind),xgrid(xind),:) = min(pos(MASK3TFa(ygrid(yind),xgrid(xind),:) + v),1);
                else
                    MASK3TFb(ygrid(yind),xgrid(xind),:) = min(pos(MASK3TFb(ygrid(yind),xgrid(xind),:) + v),1);
                end
                 
            end
         end
    end
        
    if selectedPlot==1
        if mask1a
            set(h, 'AlphaData', MASK1TFa);
        else
            set(h, 'AlphaData', MASK1TFb);
        end
         
    elseif selectedPlot==2
        if mask1a
            set(h, 'AlphaData', MASK2TFa);
        else
            set(h, 'AlphaData', MASK2TFb);
        end
    elseif selectedPlot==3
        if mask1a
            set(h, 'AlphaData', MASK3TFa);
        else
            set(h, 'AlphaData', MASK3TFb);
        end
    end


 
% --- Executes on button press in separate.
function separate_Callback(hObject, eventdata, handles)
% hObject    handle to separate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global MASK1TFa
global MASK1TFb
global MASK2TFa
global MASK2TFb
global MASK3TFa
global MASK3TFb

fig = gcf;

popup = waitbar(.5,'Please wait...');
set(popup,'windowstyle','modal');
% keep on popup on top
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1); 

mixture = getappdata(fig,'source0');
FFTSIZE = getappdata(fig,'FFTSIZE');
HOPSIZE = getappdata(fig,'HOPSIZE');
K1 = getappdata(fig,'K1');
K2 = getappdata(fig,'K2');
MAXITER = getappdata(fig,'MAXITERS');

Nz = [K1 K2];

tf = stft( mixture(:), FFTSIZE, HOPSIZE, hann(FFTSIZE));
V = abs( tf )+eps; 
Nf = size(V,1);
Nt = size(V,2);


M1 = MASK1TFa + MASK2TFa + MASK3TFa;
M2 = MASK1TFb + MASK2TFb + MASK3TFb;

[W,H] = em( V, Nz, M1, M2, MAXITER);
  
delete(popup);

%% Separate

S = W*H;
S1 = (W(:,1:Nz(1))*H(1:Nz(1),:))./S; 
S2 = (W(:,(Nz(1)+1):end)*H((Nz(1)+1):end,:))./S;
 
 
source1 = stft( tf .* S1, FFTSIZE, HOPSIZE, hann(FFTSIZE));
source2 = stft( tf .* S2, FFTSIZE, HOPSIZE, hann(FFTSIZE));

source1 = source1(1:length(mixture));
source2 = source2(1:length(mixture));
 

% update the plots and store the data
setappdata(fig,'source1', source1);
setappdata(fig,'source2', source2);

% plot 2
axes(handles.source1plot);
plotSpectrogram2(0);

% plot 3
axes(handles.source2plot);
plotSpectrogram3(0);

createAudioPlayers(0, handles);


% --- Executes on button press in playMixture.
function playMixture_Callback(hObject, eventdata, handles)
% hObject    handle to playMixture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mixture = getappdata(gcf,'mixtureap');

if ~isempty(mixture)
    if strcmp(get(hObject,'String'),'Play')
        
        if getappdata(gcf,'mixtureDirty')
            createAudioPlayers(1, handles);
        end
        mixture = getappdata(gcf,'mixtureap');
        set(mixture,'StopFcn',@StopFcn)
        resume(mixture)
        
        set(hObject,'String','||')
    else
        
        set(mixture,'StopFcn',[])
        set(hObject,'String','Play')
        pause(mixture)

    end
end

function StopFcn(obj, event, string_arg)
resume(obj)

% --- Executes on button press in playSource1.
function playSource1_Callback(hObject, eventdata, handles)
% hObject    handle to playSource1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

source1ap = getappdata(gcf,'source1ap');
if ~isempty(source1ap)
    
    if strcmp(get(hObject,'String'),'Play')
        set(source1ap,'StopFcn',@StopFcn)
        resume(source1ap)
        
        set(hObject,'String','||')
    else
        set(source1ap,'StopFcn',[])
        set(hObject,'String','Play')
        pause(source1ap)

    end
  
end


% --- Executes on button press in playSource2.
function playSource2_Callback(hObject, eventdata, handles)
% hObject    handle to playSource2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

source2ap = getappdata(gcf,'source2ap');
if ~isempty(source2ap)
     if strcmp(get(hObject,'String'),'Play')
        set(source2ap,'StopFcn',@StopFcn)
        resume(source2ap)
        
        set(hObject,'String','||')
     else
        set(source2ap,'StopFcn',[])
        set(hObject,'String','Play')
        pause(source2ap)
        
    end
end

% --- Executes on button press in stopMixture.
function stopMixture_Callback(hObject, eventdata, handles)
% hObject    handle to stopMixture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mixture = getappdata(gcf,'mixtureap');
if ~isempty(mixture)
    set(handles.playMixture,'String','Play')
    set(mixture,'StopFcn',[])
    stop(mixture)
    
end

% --- Executes on button press in stopSource1.
function stopSource1_Callback(hObject, eventdata, handles)
% hObject    handle to stopSource1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

source1ap = getappdata(gcf,'source1ap');
if ~isempty(source1ap)
    set(handles.playSource1,'String','Play')
    set(source1ap,'StopFcn',[])
    stop(source1ap)
end

% --- Executes on button press in stopSource2.
function stopSource2_Callback(hObject, eventdata, handles)
% hObject    handle to stopSource2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

source2ap = getappdata(gcf,'source2ap');
if ~isempty(source2ap)
    
    set(handles.playSource2,'String','Play')
    set(source2ap,'StopFcn',[])
    stop(source2ap)
end

 
function initCrosshairs(h_axe, h_player, d_pos_x)

    axes(h_axe); % set as current axe

    % Create and set properties of vertical crosshairs object 
    v_lim_y = get(h_axe, 'YLim');
    h_line = line([d_pos_x, d_pos_x], [v_lim_y(1), v_lim_y(2)]);
    set(h_line, 'Color', [0 1 0], 'EraseMode' , 'normal');

    %                'StopFcn', {@f_update_crosshairs_x, d_pos_x}...
    set(h_player, 'UserData', [h_line, v_lim_y],...          
                  'TimerFcn', {@updateCrosshairs, d_pos_x});           
                   
function updateCrosshairs(hco, ~, d_pos_x)

    v_handles = get(hco, 'UserData'); % get handles in current object

    if (hco.isplaying)   % only do this if playback is in progress
        d_sample_position_x = get(hco, 'CurrentSample') / get(hco, 'SampleRate');
    else
        d_sample_position_x = d_pos_x;
    end
    
    set(v_handles(1), 'XData', [d_sample_position_x, d_sample_position_x],...
                      'YData', [v_handles(2), v_handles(3)]);
 
               
function createAudioPlayers( setting, handles )

    global MASK1TFa

    fs = getappdata(gcf,'fs');

if ~setting % default 

    mixture = getappdata(gcf,'source0');
    mixtureap = audioplayer(mixture, fs);
    
    source1 = getappdata(gcf,'source1');
    source1ap = audioplayer(source1, fs);
    
    source2 = getappdata(gcf,'source2');
    source2ap = audioplayer(source2, fs);


    % TimerFcn  
    HOPSIZE = getappdata(gcf,'HOPSIZE');
    h_axe = handles.mixturePlot;
    v_time = (0:length(MASK1TFa)-1)*HOPSIZE/fs;
        
    initCrosshairs(h_axe, mixtureap, v_time(1));

    setappdata(gcf,'mixtureap',mixtureap);
    setappdata(gcf,'source1ap',source1ap);
    setappdata(gcf,'source2ap',source2ap);

    setappdata(gcf,'mixtureDirty',0)
    
else % regenreate if the mixture is dirty
 
    % check if it's dirty
    mixture = getappdata(gcf,'source0');
    
    env = ones(size(mixture));

    
    mixtureap = getappdata(gcf,'mixtureap');
    
    try
        stop(mixtureap)
    catch ME
        
    end
    mixtureap = audioplayer(mixture.*env, fs);
 
    HOPSIZE = getappdata(gcf,'HOPSIZE');
    h_axe = handles.mixturePlot;
    v_time = (0:length(MASK1TFa)-1)*HOPSIZE/fs;
    initCrosshairs(h_axe, mixtureap, v_time(1));
 
    setappdata(gcf,'mixtureap',mixtureap);
    setappdata(gcf,'mixtureDirty',0)

end

% --- Executes on slider movement.
function numComps1_Callback(hObject, eventdata, handles)
% hObject    handle to numComps1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

K1 = round(get(hObject,'Value'));
set(handles.numComps1Txt,'String',num2str(K1));
setappdata(gcf,'K1',K1)


% --- Executes during object creation, after setting all properties.
function numComps1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numComps1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function numComps2_Callback(hObject, eventdata, handles)
% hObject    handle to numComps2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
K2 = round(get(hObject,'Value'));
set(handles.numComps2Txt,'String',num2str(K2));
setappdata(gcf,'K2',K2);


% --- Executes during object creation, after setting all properties.
function numComps2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numComps2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on selection change in fftsizepopup.
function fftsizepopup_Callback(hObject, eventdata, handles)
% hObject    handle to fftsizepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fftsizepopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fftsizepopup

contents = cellstr(get(hObject,'String'));
FFTSIZE = contents{get(hObject,'Value')};
FFTSIZE = round(str2double(FFTSIZE));
setappdata(gcf,'FFTSIZE', FFTSIZE);

axes(handles.mixturePlot); 
plotSpectrogram1(1);

axes(handles.source1plot); 
plotSpectrogram2(1);

axes(handles.source2plot); 
plotSpectrogram3(1);



% --- Executes during object creation, after setting all properties.
function fftsizepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fftsizepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in hopsizepopup.
function hopsizepopup_Callback(hObject, eventdata, handles)
% hObject    handle to hopsizepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hopsizepopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hopsizepopup

contents = cellstr(get(hObject,'String'));
HOPSIZE = contents{get(hObject,'Value')};
HOPSIZE = round(str2double(HOPSIZE));
setappdata(gcf,'HOPSIZE', HOPSIZE);

axes(handles.mixturePlot) 
plotSpectrogram1(1);

axes(handles.source1plot) 
plotSpectrogram2(1);

axes(handles.source2plot) 
plotSpectrogram3(1);



% --- Executes during object creation, after setting all properties.
function hopsizepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hopsizepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 
  

% --- Executes when selected object is changed in mixsourcebuttong.
function mixsourcebuttong_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in mixsourcebuttong 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
 
 

setappdata(gcf,'mixtureDirty',1)

 

% --- Executes when selected object is changed in mixtureradio.
function mixtureradio_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in mixtureradio 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
 
 
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'mixOverlayTimeFreq1'
        setappdata(gcf, 'selectedsource', 1);
    case 'mixOverlayTimeFreq2'
        setappdata(gcf, 'selectedsource', 2);
    otherwise
        % Code for when there is no match.
end

axes(handles.mixturePlot);
plotSpectrogram1(0);
setappdata(gcf,'mixtureDirty',1);

% --- Executes when selected object is changed in source1radio.
function source1radio_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in source1radio 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'source1OverlayNone'
        setappdata(gcf, 'annotation2', 0);
    case 'source1OverlayTime'
        setappdata(gcf, 'annotation2', 1);
    case 'source1OverlayTimeFreq'
        setappdata(gcf, 'annotation2', 2);
    otherwise
        % Code for when there is no match.
end

axes(handles.source1plot)
plotSpectrogram2(0);

% --- Executes when selected object is changed in source2radio.
function source2radio_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in source2radio 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
 

%   setappdata(gcf, 'timeannotations2', 0) 
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'source2OverlayNone'
        setappdata(gcf, 'annotation3', 0);
    case 'source2OverlayTime'
        setappdata(gcf, 'annotation3', 1);
    case 'source2OverlayTimeFreq'
        setappdata(gcf, 'annotation3', 2);
    otherwise
        % Code for when there is no match.
end

axes(handles.source2plot)
plotSpectrogram3(0);



function numComps1Txt_Callback(hObject, eventdata, handles)
% hObject    handle to numComps1Txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numComps1Txt as text
%        str2double(get(hObject,'String')) returns contents of numComps1Txt as a double

K1 = round(str2double(get(hObject,'String')));
set(handles.numComps1,'Value',K1);
setappdata(gcf,'K1',K1);


% --- Executes during object creation, after setting all properties.
function numComps1Txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numComps1Txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function numComps2Txt_Callback(hObject, eventdata, handles)
% hObject    handle to numComps2Txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numComps2Txt as text
%        str2double(get(hObject,'String')) returns contents of numComps2Txt as a double

K2 = round(str2double(get(hObject,'String')));
set(handles.numComps2,'Value',K2);
setappdata(gcf,'K2',K2);


% --- Executes during object creation, after setting all properties.
function numComps2Txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numComps2Txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 
 

% --- Executes on slider movement.
function itersSlider_Callback(hObject, eventdata, handles)
% hObject    handle to itersSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
MAXITERS = round(get(hObject,'Value'));
set(handles.itersTxt,'String',num2str(MAXITERS));
setappdata(gcf,'MAXITERS',MAXITERS);

% --- Executes during object creation, after setting all properties.
function itersSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itersSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function itersTxt_Callback(hObject, eventdata, handles)
% hObject    handle to itersTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of itersTxt as text
%        str2double(get(hObject,'String')) returns contents of itersTxt as a double
MAXITERS = round(str2double(get(hObject,'String')))
set(handles.itersSlider,'Value',MAXITERS);
setappdata(gcf,'MAXITERS',MAXITERS);

% --- Executes during object creation, after setting all properties.
function itersTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itersTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function y = pos(x)
    y = 0;
    if x > 0
        y=x;
    end

function [h Xdb] = plotspec(X, fs, FFTSIZE, HOPSIZE, dbdown)

if (size(X,1) < 2) || (size(X,2) < 2)
    X = abs(stft( X(:), FFTSIZE, HOPSIZE, hann(FFTSIZE)));
end

FFTSIZE = size(X,1)*2;
nframes = size(X,2);
t = (0:nframes-1)*HOPSIZE/fs;
f = 0.001*(0:FFTSIZE-1)*(fs/2)/FFTSIZE;
Xdb = 20*log10(abs(X)+eps);
Xmax = max(max(Xdb));

% Clip lower limit to -dbdown dB so nulls don't dominate:
clipvals = [Xmax-dbdown,Xmax];
h = imagesc(t,f,Xdb,clipvals);
axis('xy');
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
set(gca, 'YTick', []);
set(gca, 'XTick', []);


 
% --------------------------------------------------------------------
function newProject_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to newProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FilterSpec = '*.wav';
[FileName,PathName,~] = uigetfile(FilterSpec);

if FileName==0
    return
end

% load file
[mixture fs] = wavread([PathName FileName]);

% sum to mono
[~,ind] = min(size(mixture));
mixture = sum(mixture,ind);

% convert to 16k
fsp = getappdata(gcf,'commonFs');
mixture = resample(mixture,fsp,fs);

setappdata(gcf,'source0', mixture);
setappdata(gcf,'fs', fsp);
source1 = mixture*0;
setappdata(gcf,'source1', source1);
setappdata(gcf,'source2', source1);

% plot 1
axes(handles.mixturePlot) 
plotSpectrogram1(1);

axes(handles.source1plot) 
plotSpectrogram2(1);

axes(handles.source2plot) 
plotSpectrogram3(1);

% create and set audio players for each sound
createAudioPlayers(0, handles);% hacks
createAudioPlayers(1, handles);
