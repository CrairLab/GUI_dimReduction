function varargout = CorrespondMaps(varargin)
% CORRESPONDMAPS MATLAB code for CorrespondMaps.fig
%      CORRESPONDMAPS, by itself, creates a new CORRESPONDMAPS or raises the existing
%      singleton*.
%
%      H = CORRESPONDMAPS returns the handle to a new CORRESPONDMAPS or the handle to
%      the existing singleton*.
%
%      CORRESPONDMAPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CORRESPONDMAPS.M with the given input arguments.
%
%      CORRESPONDMAPS('Property','Value',...) creates a new CORRESPONDMAPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CorrespondMaps_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CorrespondMaps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%      Author: Yixiang Wang
%      Contact: yixiang.wang@yale.edu
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CorrespondMaps

% Last Modified by GUIDE v2.5 18-Feb-2020 14:29:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CorrespondMaps_OpeningFcn, ...
                   'gui_OutputFcn',  @CorrespondMaps_OutputFcn, ...
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


% --- Executes just before CorrespondMaps is made visible.
function CorrespondMaps_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CorrespondMaps (see VARARGIN)

% Choose default command line output for CorrespondMaps

% Choose default command line output for CorrespondMaps
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


if size(varargin,1) > 0
    try
        curObj = varargin{1};
        hObject.UserData = curObj;
    catch
        warning('Please load dimReuction object!')
    end
end

if ~isempty(findobj('Tag', 'GUI_dimReduction'))
    %Load data from GUI_dimReduction
    dimR_h = findobj('Tag', 'GUI_dimReduction');
    dimR_data = guidata(dimR_h);
    dimRObj = get(dimR_data.output, 'UserData');
    handles.output.UserData = dimRObj;
    %Show status
    set(handles.Show_status, 'ForegroundColor', 'Red')
    handles.Show_status.String = 'Loaded object from GUI_dimReduction';
    % Show reference brain map at axes1
    A_mean = dimRObj.A_ref;
    imshow(mat2gray(A_mean), 'Parent', handles.axes1);
    hold(handles.axes1, 'on');
    %Define default max K
    handles.Max_K.String = '15';
end



% UIWAIT makes CorrespondMaps wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CorrespondMaps_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_dimReductionObj.
function Load_dimReductionObj_Callback(hObject, eventdata, handles)
% hObject    handle to Load_dimReductionObj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to load dimReduction object from the main GUI or from .mat file

if isempty(get(handles.output, 'UserData')) %If no input from the main GUI
    try
        uiopen('Please load a dimReduction object'); %Try load .mat file
        %Show progress
        set(handles.Show_status, 'String', 'Object loaded from dialog window!')        
    catch
        warning('Please load a dimReduction object')
    end
    
    %Save the loaded data into variable curObj
    vList = whos; 
    for i = 1:size(vList,1)
        if strcmp(vList(i).class, 'dimReduction')
            curObj = eval(vList(i).name);
            set(handles.output, 'UserData', curObj);
            break
        end
    end
else
    %Show progress
    set(handles.Show_status, 'String', 'Object loaded from GUI_dimReduction!')   
end

set(handles.Show_status, 'ForegroundColor', 'Red')

function runCorrespondMaps(curObj, handles, methodflag, mapflag)
% Correspond dimReduction map with reference brain map or frame(s)
% Inputs:
%   curObj    input dimReduction object
%   handles   UI component handles
%   methodflag     0 for pixelwise, 1 for framewise
%   mapflag   1 for tSNE, 2 for diffusion map

if nargin<3
    mapflag = 1;
end

% Show reference brain map at axes1
A_mean = curObj.A_ref;
imshow(mat2gray(A_mean), 'Parent', handles.axes1);
hold(handles.axes1, 'on');

% Choose which map to plot
switch mapflag
    case 1
    Embedding = curObj.Y;
    case 2
    Embedding = curObj.Dmap;
end

% Plot the map in a different figure.
cmap = 1:size(Embedding,1);
fig1 = figure;
map_handle = scatter3(Embedding(:,1),Embedding(:,2),Embedding(:,3),[],cmap,'filled');
colorbar;
colormap copper;
%map_handle = plot3(Embedding(:,1),Embedding(:,2),Embedding(:,3));

% Save the handles info as a struct data affiliated to the figure.
data.map_handle = map_handle;
data.handles = handles;
fig1.UserData =  data;

% Allow callback function of brushed data. 
if ~methodflag
    
    % For framewise correspondence
    % Get the handle of the brush function
    h = brush(fig1);
    set(h, 'Enable', 'On', 'ActionPostCallback', @callbackGetSelectedData);
    
elseif methodflag
    
    % For pixelwise correspondence, first reconstruct 3D movie
    try
        sz_fd = curObj.sz_fd;
        A_rcs = nan(sz_fd(1)*sz_fd(2), sz_fd(3)); %Reconstructed matrix
        A_rd = curObj.A_rd;
        %Transpose the A_rd if it is framewise analysis
        if curObj.tflag == 1
            A_rd = A_rd';
        end
        %Reconstruct 3D movie from 2D A_rd.
        try
            A_rcs(curObj.subIdx,:) = A_rd;
        catch
            A_rcs(curObj.subIdx,:) = A_rd';
        end
        A_rcs = reshape(A_rcs, sz_fd);
    catch
        warning('Can not reconstruct 3D movie from the 2D matrix!')
    end
    %Update data struct
    data.A_rcs = A_rcs;
    fig1.UserData =  data;
    % Get the handle of the brush function
    h = brush(fig1);
    set(h, 'Enable', 'On', 'ActionPostCallback', @callbackClickA3DPoint);
end
    
function callbackClickA3DPoint(src, ~)
% Callback function for framewise correspondence (correspond reduced points 
% to movie frames)
% Inputs:
%   src    handle of current figure
    
    %Select the first point in a set of brushed points
    disp('Please only select one point!')
    data = src.UserData;
    brush_data = get(data.map_handle, 'BrushData');
    brushed_idx = find(brush_data);
    firstIdx = brushed_idx(1);
    %Save to index to the data struct
    data.brushed = firstIdx;
    %Update UserData of the figure
    src.UserData = data;
    %Get the handles of GUI components
    handles = data.handles;
    try
        %Get the corresponding frame
        A_rcs = data.A_rcs;
        correspondFrame = A_rcs(:,:,firstIdx);
        imshow(mat2gray(correspondFrame), 'Parent', handles.axes1);
        set(handles.Show_status, 'String', ['Frame #' num2str(firstIdx)])
    catch
        warning('Can not display corresponding frame!')
    end
    


function callbackGetSelectedData(src, ~)
% Callback function for pixelwise correspondence (correspond reduced points 
% to pixels in the reference brain map)
% Inputs:
%   src    handle of current figure
    
    %Get the brushed data from the scatter object
    data = src.UserData;
    brush_data = get(data.map_handle, 'BrushData');
    %Find the corresponding pixel indicies
    brushed_idx = find(brush_data);
    %Save the indicies in the data struct
    data.brushed = brushed_idx;
    %Update the UserData
    src.UserData = data;
    handles = data.handles;
    
    try %Try to highlight the corresponding pixels in the reference brain map
        curObj = get(handles.output, 'UserData');
        xy_sub = curObj.xy_sub;
        %imshow(mat2gray(A_mean), 'Parent', handles.axes1);
        %A_mean = curObj.A_ref;
        %imshow(mat2gray(A_mean), 'Parent', handles.axes1);
        hold(handles.axes1, 'on');
        %plot(handles.axes1,xy_sub(brushed_idx,2),xy_sub(brushed_idx,1),'r.')
        scatter(handles.axes1,xy_sub(brushed_idx,2),xy_sub(brushed_idx,1),50,'filled')
        %hold(handles.axes1, 'off');
    catch
        warning('Can not load xy subscripts!')
    end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Load_dimReductionObj.
function Load_dimReductionObj_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Load_dimReductionObj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






function Show_status_Callback(hObject, eventdata, handles)
% hObject    handle to Show_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_status as text
%        str2double(get(hObject,'String')) returns contents of Show_status as a double


% --- Executes during object creation, after setting all properties.
function Show_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Run_correspond.
function Run_correspond_Callback(hObject, eventdata, handles)
% hObject    handle to Run_correspond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to run the runCorrespondMaps function

% Get the dimReduction object
curObj = get(handles.output, 'UserData');
tflag = curObj.tflag;
mapflag = get(handles.Choose_type, 'Value');

if tflag == 0 %Pixelwise
    set(handles.Show_status, 'String', 'Pixelwise correspondence!')
elseif tflag == 1 %Framewise
    set(handles.Show_status, 'String', 'Framewise correspondence!')
end

runCorrespondMaps(curObj, handles, tflag, mapflag)


% --- Executes on selection change in Choose_type.
function Choose_type_Callback(hObject, eventdata, handles)
% hObject    handle to Choose_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Choose_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Choose_type


% --- Executes during object creation, after setting all properties.
function Choose_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Choose_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Renew_axes.
function Renew_axes_Callback(hObject, eventdata, handles)
% hObject    handle to Renew_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to renew/reset the reference map

% Get the dimReduction object
curObj = get(handles.output, 'UserData');
% Reset the reference map
A_mean = curObj.A_ref;
hold(handles.axes1, 'off');
imshow(mat2gray(A_mean), 'Parent', handles.axes1);
hold(handles.axes1, 'on');


% --- Executes on button press in Run_Kmeans.
function Run_Kmeans_Callback(hObject, eventdata, handles)
% hObject    handle to Run_Kmeans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Show_status.String = 'Running Kmeans analysis!';
curObj = handles.output.UserData;

%See whether run on raw dFoF trace instead on reduced data
rawflag = get(handles.Run_raw, 'Value');
if rawflag
    mapflag = 0;
    disp('Run on raw input (dFoF traces)!')
else
    %Choose which type of data to use;
    mapflag = get(handles.Choose_type, 'Value');
end

switch mapflag
    case 0
        Embedding = curObj.A_rd;    
    case 1
        Embedding = curObj.Y;   
    case 2
        A_rd = curObj.A_rd;
        %Redo diffusion map analysis using information from all dims
        Dmap = dimReduction.diffmap(A_rd, 2, size(A_rd,1)-1, []);
        Embedding = Dmap;
end

%checkname = ['Kmeans_result_' num2str(mapflag) '*'];

%Get Maximum K to search
if isnan(str2double(handles.Max_K.String))
    msgbox('Please input a valid interger!')
    return
else
    Max_K = str2double(handles.Max_K.String);
end

%Kmeans: 20 replicates
if rawflag
    Kmeans_10 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate', 10, 'Distance', 'correlation'));
else
    Kmeans_10 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
        'replicate',10));
end
All_K = [];

%Evaluate using DaviesBouldin 10 times to get the best K
for i = 1:10
    cur_eva = evalclusters(Embedding,Kmeans_10,'DaviesBouldin','KList',[1:Max_K]);
    All_K(i) = cur_eva.OptimalK;
    disp([num2str(i) 'th evaluation...'])
end
OptimalK = mode(All_K);
disp(['Best K identified by Davies-Bouldin is: ' num2str(OptimalK)]);
handles.Show_status.String = ['Best K is: ' num2str(OptimalK)];

%Kmeans: 100 replicates
if rawflag
    Kmeans_100 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate',100, 'Distance', 'correlation'));
else
    Kmeans_100 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
        'replicate',100));
end

%Revaluate using optimal K and 100 replicates
%OptimalK_eva = evalclusters(Embedding,Kmeans_100,'DaviesBouldin','KList',[1:Max_K]);
[idx,C] = Kmeans_100(Embedding,OptimalK);
c = clock;
timetag = ['_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))];

%Store useful variables
handles.Run_Kmeans.UserData.OptimalK = OptimalK;
handles.Run_Kmeans.UserData.idx = idx;
handles.Run_Kmeans.UserData.timetag = timetag;
handles.Run_Kmeans.UserData.mapflag = mapflag;

%Get representative traces of clusters by doing averaging within clusters
A_rd = curObj.A_rd;
Rep_traces = nan(OptimalK, size(A_rd,2));
for k = 1:OptimalK
    cur_cluster = [idx == k];
    Rep_traces(k,:) = nanmean(A_rd(cur_cluster,:),1);
end

%Save useful variables
uisave({'idx', 'C', 'OptimalK', 'OptimalK_eva','Rep_traces', 'Embedding'...
    , 'mapflag', 'timetag'}, ['Kmeans_result_' num2str(mapflag) timetag '.mat'])



function Max_K_Callback(hObject, eventdata, handles)
% hObject    handle to Max_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Max_K as text
%        str2double(get(hObject,'String')) returns contents of Max_K as a double


% --- Executes during object creation, after setting all properties.
function Max_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Project_result.
function Project_result_Callback(hObject, eventdata, handles)
% hObject    handle to Project_result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get relevent variables
curObj = handles.output.UserData;
try
    OptimalK = handles.Run_Kmeans.UserData.OptimalK;
    idx = handles.Run_Kmeans.UserData.idx;
    timetag = handles.Run_Kmeans.UserData.timetag;
    mapflag = handles.Run_Kmeans.UserData.mapflag;
catch
    warning('Can not detect information for projection within the GUI!')
    uiopen('Please load the Kmeans result!');
end

try %Try to highlight the corresponding pixels in the reference brain map
        K_colormap = hsv(OptimalK);
        xy_sub = curObj.xy_sub;
        
        %Construct representative trace for each cluster
        A_rd = curObj.A_rd;
        Rep_traces = nan(OptimalK, size(A_rd,2));
        for k = 1:OptimalK
            cur_color = K_colormap(k,:);
            cur_cluster = [idx == k];
            set(handles.figure1,'CurrentAxes',handles.axes1)
            hold(handles.axes1, 'on');
            scatter(xy_sub(cur_cluster,2),xy_sub(cur_cluster,1),...
                20, cur_color, 'filled')            
            %Use the average of all the pixels in one cluster as
            %representative trace
            Rep_traces(k,:) = nanmean(A_rd(cur_cluster,:),1);
        end
        %colormap(handles.axes1,'jet')
        hold(handles.axes1, 'off');
        saveas(handles.figure1,['Clustering_result_' num2str(mapflag) ...
            '_OptimalK_' num2str(OptimalK) timetag '.png'])
        %hold(handles.axes1, 'off');
catch
    msgbox('Something wrong! Please make sure you load the right file or rerun Kmeans!'...
        , 'Error!')
end


% --- Executes on button press in Run_raw.
function Run_raw_Callback(hObject, eventdata, handles)
% hObject    handle to Run_raw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Run_raw
