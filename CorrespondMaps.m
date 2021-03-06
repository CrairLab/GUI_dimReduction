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

% Last Modified by GUIDE v2.5 30-Dec-2020 14:16:10

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
%   mapflag   1 for tSNE, 2 for diffusion map, 3 for PHATE

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
    case 3
    Embedding = curObj.PT;
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


% --- Executes on button press in Eva_Kmeans.
function Eva_Kmeans_Callback(hObject, eventdata, handles)
% hObject    handle to Eva_Kmeans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Show_status.String = 'Running Kmeans evaluatioin!';
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

%Get Maximum K to search
if isnan(str2double(handles.Max_K.String))
    msgbox('Please input a valid interger!')
    return
else
    Max_K = str2double(handles.Max_K.String);
end

Embedding = getEmbedding(curObj, mapflag, Max_K);

%checkname = ['Kmeans_result_' num2str(mapflag) '*'];

%Kmeans: 20 replicates
if rawflag
    Kmeans_10 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate', 10, 'Distance', 'correlation'));
    Kmeans_100 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate',100, 'Distance', 'correlation'));
else
    Kmeans_10 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate',10));
    Kmeans_100 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate',100));
end

All_K = [];

criterion_flag = get(handles.Criterion, 'Value');
%allBIC = [];

switch criterion_flag
    case 1
        msgbox('Please select an evaluation criterion!')
    case 2
        %Use the xmeans criterion
        OptimalK_eva = [];
        for i = 1:10
            [~, ~, curOptimal, curBIC] = XMeans(Embedding, Max_K, 1000);
            %allBIC = [allBIC; curBIC];
            if length(curBIC) == 1
                curOptimal = 1;
            else
                disp('Use Xmeans criterion...')          
            end
            OptimalK_eva = [OptimalK_eva curOptimal];
            display(['Repeat #' num2str(i)]) 
        end
        OptimalK = ceil(median(OptimalK_eva));
        disp(['Optimal K = ' num2str(OptimalK)]);
        msgbox(['Optimal K = ' num2str(OptimalK)])
        %[idx,C] = Kmeans_100(Embedding,OptimalK);
    case 3
        %Use the BIC criterion
        [OptimalK_eva, bic_knee, bic_laplacian, bic_max] = bestBIC(Embedding, Max_K);
        msgbox(['BIC knee = ' num2str(bic_knee) ...
            '; BIC laplacian = ' num2str(bic_laplacian) ...
            ': BIC max = ' num2str(bic_max)])
        OptimalK = min([bic_knee, bic_laplacian, bic_max]);
    case 4
        %Evaluate using DaviesBouldin 10 times to get the best K
        for i = 1:10
            cur_eva = evalclusters(Embedding,Kmeans_10,'DaviesBouldin','KList',[1:Max_K]);
            All_K(i) = cur_eva.OptimalK;
            disp([num2str(i) 'th evaluation...'])
        end
        OptimalK = mode(All_K);
        disp(['Best K identified by Davies-Bouldin is: ' num2str(OptimalK)]);
        handles.Show_status.String = ['Best K is: ' num2str(OptimalK)];

        %Revaluate using optimal K and 100 replicates
        OptimalK_eva = evalclusters(Embedding,Kmeans_100,'DaviesBouldin','KList',[1:Max_K]);
        %[idx,C] = Kmeans_100(Embedding,OptimalK);   
end

%Record current time
c = clock;
timetag = ['_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))];

%Store useful variables
handles.Eva_Kmeans.UserData.OptimalK = OptimalK;
%handles.Eva_Kmeans.UserData.idx = idx;
handles.Eva_Kmeans.UserData.timetag = timetag;
handles.Eva_Kmeans.UserData.mapflag = mapflag;
handles.Eva_Kmeans.UserData.criterion_flag = criterion_flag;

set(handles.Final_K, 'String', num2str(OptimalK));
%Pass the embeddings to Runkmeans
%handles.Runkmeans.UserData.Embedding = Embedding;




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
    try
        BestK = handles.Runkmeans.UserData.BestK;
        disp(['Current K for projection is: ' num2str(BestK)])
        idx = handles.Eva_Kmeans.UserData.idx;
    catch
        msgbox('Please click Run Kmeans first!')
    end
    timetag = handles.Eva_Kmeans.UserData.timetag;
    mapflag = handles.Eva_Kmeans.UserData.mapflag;
catch
    warning('Can not detect information for evaluation within the GUI!')
    warning('Getting result from direct Kmeans running')
    mapflag = -1;
    c = clock;
    timetag = ['_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))];
    %uiopen('Please load the Kmeans result!');
end

try %Try to highlight the corresponding pixels in the reference brain map
        BestK = handles.Runkmeans.UserData.BestK;
        K_colormap = hsv(BestK);
        xy_sub = curObj.xy_sub;
        
        %Construct representative trace for each cluster
        A_rd = curObj.A_rd;
        Rep_traces = nan(BestK, size(A_rd,2));
        for k = 1:BestK
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
            '_BestK_' num2str(BestK) timetag '.png'])
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


% --- Executes on button press in Criterion.
function Criterion_Callback(hObject, eventdata, handles)
% hObject    handle to Criterion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Criterion



function Final_K_Callback(hObject, eventdata, handles)
% hObject    handle to Final_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Final_K as text
%        str2double(get(hObject,'String')) returns contents of Final_K as a double


% --- Executes during object creation, after setting all properties.
function Final_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Final_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Runkmeans.
function Runkmeans_Callback(hObject, eventdata, handles)
% hObject    handle to Runkmeans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%See whether run on raw dFoF trace instead on reduced data
rawflag = get(handles.Run_raw, 'Value');
%Get current object
curObj = handles.output.UserData;

if rawflag
    mapflag = 0;
    disp('Run on raw input (dFoF traces)!')
else
    %Choose which type of data to use;
    mapflag = get(handles.Choose_type, 'Value');
end

%Kmeans: 20 replicates
if rawflag
    Kmeans_10 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate', 10, 'Distance', 'correlation'));
    Kmeans_100 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate',100, 'Distance', 'correlation'));
else
    Kmeans_10 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate',10));
    Kmeans_100 = @(X,K)(kmeans(X, K, 'emptyaction','drop',...
    'replicate',100));
end

%Get the best K to run kmenas
try
    %Get the best K to run kmeans
    BestK = str2double(get(handles.Final_K, 'String'));
    Embedding = getEmbedding(curObj, mapflag, BestK);
    [idx,C] = Kmeans_100(Embedding, BestK);
    %Store the idx and BestK
    handles.Eva_Kmeans.UserData.idx = idx;
    handles.Runkmeans.UserData.BestK = BestK;
catch
    msgbox('Please evaluate kmeans and choose the best K!')
end

%Get representative traces of clusters by doing averaging within clusters
A_rd = curObj.A_rd;
Rep_traces = nan(BestK, size(A_rd,2));
for k = 1:BestK
    cur_cluster = [idx == k];
    Rep_traces(k,:) = nanmean(A_rd(cur_cluster,:),1);
end

%Store representative traces
handles.Eva_Kmeans.UserData.Rep_traces = Rep_traces;

%Get the Eva_kemans struct
Eva_kmeans = handles.Eva_Kmeans.UserData;

if isfield(Eva_kmeans, 'mapflag')
    mapflag = Eva_kmeans.mapflag;
    timetag = Eva_kmeans.timetag;
    criterion_flag = Eva_kmeans.criterion_flag;
    %Save useful variables
    uisave({'Eva_kmeans', 'idx', 'C'}, ['Kmeans_result_BestK_' num2str(BestK) ...
        '_mapflag_' num2str(mapflag) '_criterion_' num2str(criterion_flag)...
        '_' timetag '.mat'])
else
    uisave({'idx', 'C'}, ['Kmeans_result_BestK_' num2str(BestK) '_woEva.mat'])
    msgbox('Please evaluate kmenas first!')
end






function Embedding = getEmbedding(curObj, mapflag, Max_K)
%Get embedding given mapflag
    switch mapflag
        case 15
            Embedding = curObj.A_rd;    
        case 1
            Embedding = curObj.Y;   
        case 2
            %A_rd = curObj.A_rd;
            %Redo diffusion map analysis using information from all dims
            %Dmap = dimReduction.diffmap(A_rd, 2, size(A_rd,1)-1, [], curObj.adaptive);
            psi = curObj.dParam.psi;
            vals = curObj.dParam.vals;
            t = curObj.dParam.t;
            if nargin < 3
                Dmap = psi(:,2:end).*(vals(2:end)'.^t);
            else
                Dmax = min(size(psi,2), Max_K + 1);
                Dmap = psi(:,2:Dmax).*(vals(2:Dmax)'.^t);
            end
            Embedding = Dmap;
            disp(['Reconstructed Dmap dimension = ' num2str(size(Dmap,2))])
        case 3
            Embedding = curObj.PT; %PHATE
    end