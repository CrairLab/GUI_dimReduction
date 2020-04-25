function varargout = GUI_dimReduction(varargin)
% GUI_DIMREDUCTION MATLAB code for GUI_dimReduction.fig
%      GUI_DIMREDUCTION, by itself, creates a new GUI_DIMREDUCTION or raises the existing
%      singleton*.
%
%      H = GUI_DIMREDUCTION returns the handle to a new GUI_DIMREDUCTION or the handle to
%      the existing singleton*.
%
%      GUI_DIMREDUCTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DIMREDUCTION.M with the given input arguments.
%
%      GUI_DIMREDUCTION('Property','Value',...) creates a new GUI_DIMREDUCTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_dimReduction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_dimReduction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%      Author: Yixiang Wang
%      Contact: yixiang.wang@yale.edu
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_dimReduction

% Last Modified by GUIDE v2.5 06-Feb-2020 11:31:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_dimReduction_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_dimReduction_OutputFcn, ...
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


% --- Executes just before GUI_dimReduction is made visible.
function GUI_dimReduction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_dimReduction (see VARARGIN)

% Choose default command line output for GUI_dimReduction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Get the plotCorrObj from the main GUI (LineMapScan)
if ~isempty(findobj('Tag', 'LineMapScan'))
    MC_h = findobj('Tag', 'LineMapScan');
    MC_data = guidata(MC_h);
    LineMapObj = get(MC_data.Load_rectangle, 'UserData');
    
    Avg_line = LineMapObj.Avg_line;
    Avg_line = reshape(Avg_line', [1, size(Avg_line,2), size(Avg_line,1)]);
    
    handles.Save_dimReduction.UserData.filename = LineMapObj.filename;
    handles.Load_movie.UserData = Avg_line;
    
    set(handles.Report_progres, 'Visible', 'On')
    set(handles.Report_progres, 'String', 'Loaded from LineMapScan')
    clear LineMapObj;
    
    disp('Loaded object from GUI LineMapScan!')
end
    
    
    

% UIWAIT makes GUI_dimReduction wait for user response (see UIRESUME)
% uiwait(handles.GUI_dimReduction);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_dimReduction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_movie.
function Load_movie_Callback(hObject, eventdata, handles)
% hObject    handle to Load_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Load movie button.

    %load dFoF movie using uiopen
    set(handles.Report_progres, 'Visible', 'On')
    set(handles.Report_progres, 'String', 'Loading...')
    
    uiopen('Please load the 3D dF over F movie!')
    
    %Store the movie into a variable curMovie
    try
        vList = whos; 
        for i = 1:size(vList,1)
            %Search for 3D matrix
            if length(vList(i).size) == 3 
                curMovie = eval(vList(i).name);
                hObject.UserData = curMovie;
                set(handles.Report_progres, 'String', 'Finished!')
                break
            end
        end  
    catch
        set(handles.Report_progres, 'String', 'Error!')
        warning('Can not load the dF over F movie!')        
    end

% --- Executes on selection change in Choose_type.
function Choose_type_Callback(hObject, eventdata, handles)
% hObject    handle to Choose_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Popupmenu to choose whether do pixelwise or framewise analysis

%Load existed initial parameters
iniParameters = get(handles.Use_default, 'UserData');
contents = cellstr(get(hObject, 'String'));
curString = contents{get(hObject,'Value')};
if strcmp(curString, 'Pixelwise')
        iniParameters.tflag = 0;
elseif strcmp(curString, 'Framewise')
        iniParameters.tflag = 1;
end

%Update initial parameters
set(handles.Use_default, 'UserData', iniParameters);

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


% --- Executes on key press with focus on Choose_type and none of its controls.
function Choose_type_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Choose_type (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Load_movie.
function Load_dimReduction_Callback(hObject, eventdata, handles)
% hObject    handle to Load_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to load an existed dimReduction object

set(handles.Load_status, 'Visible', 'On')
set(handles.Load_status, 'String', 'Wait')

%Open a saved dimReduction object using dialog window
try
    uiopen('Please load a dimReduction object');
catch
    warning('Please load a dimReduction object')
end

%Store the loaded object to a variable curObj
vList = whos; 
for i = 1:size(vList,1)
    if strcmp(vList(i).class, 'dimReduction')
        curObj = eval(vList(i).name);
        set(handles.output, 'UserData', curObj)
        set(handles.Load_status, 'Visible', 'Off')
        break
    end
end
set(handles.output, 'UserData', curObj);

%Redisplay parameters;
displayParam(curObj, handles);

%Plot tSNE and diffusion map
plotAxes(curObj, handles);

% --- Executes on selection change in Choose_type.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to Choose_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Choose_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Choose_type


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Choose_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Use_default.
function Use_default_Callback(hObject, eventdata, handles)
% hObject    handle to Use_default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to load default parameters

%Set default parameters
%pixelwise analysis
iniParameters.tflag = 0;
set(handles.Choose_type,'Value',2);
%Do not constraint on location
iniParameters.locflag = 0;
set(handles.Constrain_loc,'Value',0);
iniParameters.locfactor = 0;
set(handles.Spatial_factor,'String',num2str(0));
set(handles.Constrain_coeff,'Value',0);
%Downsample by 2 both temporally and spatially
iniParameters.fd = [2, 2];
set(handles.Spatial_factor,'Value',2);
set(handles.Spatial_factor,'String',num2str(2));
set(handles.Temporal_factor,'Value',2);
set(handles.Temporal_factor,'String',num2str(2));
%Save default parameters;
hObject.UserData = iniParameters;



% --- Executes on button press in Constrain_loc.
function Constrain_loc_Callback(hObject, eventdata, handles)
% hObject    handle to Constrain_loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Checkbox to choose whether inject location information into analysis

% Hint: get(hObject,'Value') returns toggle state of Constrain_loc
iniParameters = get(handles.Use_default, 'UserData');
curValue = get(hObject, 'Value');
if curValue == 0 
        iniParameters.locflag = 0;
elseif curValue == 1
        iniParameters.locflag = 1;
end
set(handles.Use_default, 'UserData', iniParameters);


function Constrain_coeff_Callback(hObject, eventdata, handles)
% hObject    handle to Constrain_coeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Constrain_coeff as text
%        str2double(get(hObject,'String')) returns contents of Constrain_coeff as a double
iniParameters = get(handles.Use_default, 'UserData');
iniParameters.locfactor = str2double(get(hObject, 'String'));
set(handles.Use_default, 'UserData', iniParameters);

% --- Executes during object creation, after setting all properties.
function Constrain_coeff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Constrain_coeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Run_dimReduction.
function Run_dimReduction_Callback(hObject, eventdata, handles)
% hObject    handle to Run_dimReduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to run dimReduction analysis/construct dimReduction object

%Show progress
set(handles.Run_status, 'Visible', 'On')
set(handles.Run_status, 'String', 'Running...')

%Load parameters
param = get(handles.Use_default, 'UserData');
curMovie = get(handles.Load_movie, 'UserData');

%Run dimReduction
try
    curObj = dimReduction(curMovie, param.tflag, param.locflag,...
        param.locfactor, param.fd);
    set(handles.Run_status, 'String', 'Finished!')
catch
    set(handles.Run_status, 'String', 'Error!')
end
set(handles.output, 'UserData', curObj);

%Redisplay parameters;
displayParam(curObj, handles)

%Plot tSNE and diffusion map
plotAxes(curObj, handles);

function Spatial_factor_Callback(hObject, eventdata, handles)
% hObject    handle to Spatial_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Spatial_factor as text
%        str2double(get(hObject,'String')) returns contents of Spatial_factor as a double
iniParameters = get(handles.Use_default, 'UserData');
iniParameters.fd(1) = str2double(get(hObject, 'String'));
set(handles.Use_default, 'UserData', iniParameters);

% --- Executes during object creation, after setting all properties.
function Spatial_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Spatial_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Temporal_factor_Callback(hObject, eventdata, handles)
% hObject    handle to Temporal_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Temporal_factor as text
%        str2double(get(hObject,'String')) returns contents of Temporal_factor as a double
iniParameters = get(handles.Use_default, 'UserData');
iniParameters.fd(2) = str2double(get(hObject, 'String'));
set(handles.Use_default, 'UserData', iniParameters);

% --- Executes during object creation, after setting all properties.
function Temporal_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Temporal_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Use_default_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Use_default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Pushbutton to load default parameters
iniParameters.tflag = 0;
%Do not constraint on location
iniParameters.locflag = 0;
iniParameters.locfactor = 0;
%Downsample by 2 both temporally and spatially
iniParameters.fd = [2, 2];
%Save default parameters;
hObject.UserData = iniParameters;



function tSNE_status_Callback(hObject, eventdata, handles)
% hObject    handle to tSNE_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tSNE_status as text
%        str2double(get(hObject,'String')) returns contents of tSNE_status as a double


% --- Executes during object creation, after setting all properties.
function tSNE_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSNE_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Run_status_Callback(hObject, eventdata, handles)
% hObject    handle to Run_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Run_status as text
%        str2double(get(hObject,'String')) returns contents of Run_status as a double


% --- Executes during object creation, after setting all properties.
function Run_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Run_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Report_progres_Callback(hObject, eventdata, handles)
% hObject    handle to Report_progres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Report_progres as text
%        str2double(get(hObject,'String')) returns contents of Report_progres as a double


% --- Executes during object creation, after setting all properties.
function Report_progres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Report_progres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tSNE_perplexity_Callback(hObject, eventdata, handles)
% hObject    handle to tSNE_perplexity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tSNE_perplexity as text
%        str2double(get(hObject,'String')) returns contents of tSNE_perplexity as a double


% --- Executes during object creation, after setting all properties.
function tSNE_perplexity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSNE_perplexity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tSNE_Exaggeration_Callback(hObject, eventdata, handles)
% hObject    handle to tSNE_Exaggeration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tSNE_Exaggeration as text
%        str2double(get(hObject,'String')) returns contents of tSNE_Exaggeration as a double


% --- Executes during object creation, after setting all properties.
function tSNE_Exaggeration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSNE_Exaggeration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tSNE_Renew.
function tSNE_Renew_Callback(hObject, eventdata, handles)
% hObject    handle to tSNE_Renew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to renew tSNE analysis using new parameters

%Show progress
set(handles.tSNE_status, 'Visible', 'On')
set(handles.tSNE_status, 'String', 'Running...')

%Load renewed parameters
tParam = get(handles.tSNE_control, 'UserData');
tParam.px = str2double(get(handles.tSNE_perplexity, 'String'));
tParam.Exaggeration = str2double(get(handles.tSNE_Exaggeration, 'String'));
contents = cellstr(get(handles.popupmenu2, 'String'));
curString = contents{get(handles.popupmenu2,'Value')};
tParam.Distance = curString;
set(hObject.Parent, 'UserData', tParam);

%Redo tSNE using new parameters
curObj = get(handles.output, 'UserData');
curObj.tParam = tParam;
curObj.Y = dimReduction.doTSNE(curObj.A_rd, tParam);
set(handles.output, 'UserData', curObj);
set(handles.tSNE_status, 'String', 'Finished!')

%Redisplay parameters;
displayParam(curObj, handles);

%Renew the current plots
plotAxes(curObj, handles);


% --- Executes during object creation, after setting all properties.
function tSNE_control_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSNE_control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Load default tSNE parameters
tParam.Distance = 'euclidean';
tParam.nd = 3;
tParam.np = 50;
tParam.px = 30;
tParam.stdFlag = false;
tParam.vflag = 1;
tParam.Exaggeration = 8;
tParam.options = statset('MaxIter', 500);
hObject.UserData = tParam;



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dmap_dims_Callback(hObject, eventdata, handles)
% hObject    handle to Dmap_dims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dmap_dims as text
%        str2double(get(hObject,'String')) returns contents of Dmap_dims as a double


% --- Executes during object creation, after setting all properties.
function Dmap_dims_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dmap_dims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dmap_sigma_Callback(hObject, eventdata, handles)
% hObject    handle to Dmap_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dmap_sigma as text
%        str2double(get(hObject,'String')) returns contents of Dmap_sigma as a double


% --- Executes during object creation, after setting all properties.
function Dmap_sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dmap_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Dmap_Renew.
function Dmap_Renew_Callback(hObject, eventdata, handles)
% hObject    handle to Dmap_Renew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to renew diffusion map analysis using new parameters

%Show progress
set(handles.Dmap_status, 'Visible', 'On')
set(handles.Dmap_status, 'String', 'Running...')

%Get renewed parameters
dParam = get(handles.Dmap_control, 'UserData');
dParam.t = str2double(get(handles.edit9, 'String'));
dParam.m = str2double(get(handles.Dmap_dims, 'String'));
dParam.sigma = str2double(get(handles.Dmap_sigma, 'String'));
set(hObject.Parent, 'UserData', dParam);

%Redo diffusion map using new parameters
curObj = get(handles.output, 'UserData');
[curObj.Dmap, curObj.dParam, ~] = ...
    dimReduction.diffmap(curObj.A_rd, dParam.t, dParam.m, dParam.sigma);
set(handles.output, 'UserData', curObj);
set(handles.Dmap_status, 'String', 'Finished!')

%Redisplay parameters;
curObj.dParam = dParam;
displayParam(curObj, handles);

%Renew the current plots
plotAxes(curObj, handles);


function Dmap_status_Callback(hObject, eventdata, handles)
% hObject    handle to Dmap_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dmap_status as text
%        str2double(get(hObject,'String')) returns contents of Dmap_status as a double


% --- Executes during object creation, after setting all properties.
function Dmap_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dmap_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Dmap_control_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dmap_control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Load default parameters for diffusion maps
dParam.t = 2;
dParam.m = 3;
dParam.sigma = [];
hObject.UserData = dParam;



function displayParam(curObj, handles)
% display parameters in edit-text boxes
% Inputs:
% curObj     input dimReduction object
% handles    handles of UI components

%Display parameters for dimReduction
set(handles.Choose_type,'Value', curObj.tflag + 2);
%Do not constraint on location
set(handles.Constrain_loc,'Value',curObj.locflag);
set(handles.Constrain_coeff,'Value',0);
%Downsample by 2 both temporally and spatially
set(handles.Spatial_factor,'String',num2str(curObj.fd(1)));
set(handles.Temporal_factor,'String',num2str(curObj.fd(2)));

%Display tSNE parameters
tParam = curObj.tParam;
set(handles.tSNE_perplexity, 'String', num2str(tParam.px));
set(handles.tSNE_Exaggeration, 'String', num2str(tParam.Exaggeration));

contents = cellstr(get(handles.popupmenu2,'String'));
curVal = find(strcmp(contents, tParam.Distance));
set(handles.popupmenu2, 'Value', curVal);

%Display diffusion map parameters
dParam = curObj.dParam;
set(handles.edit9, 'String', num2str(dParam.t));
set(handles.Dmap_dims, 'String', num2str(dParam.m));
set(handles.Dmap_sigma, 'String', num2str(dParam.sigma));




function plotAxes(curObj, handles)
% plot in Axes (renew tSNE map and diffusion map)
% Inputs:
% curObj     input dimReduction object
% handles    handles of UI components

curY = curObj.Y;
curDmap = curObj.Dmap;

cmap = 1:size(curY,1);
scatter3(handles.tSNE_axes, curY(:,1),curY(:,2),curY(:,3),[],cmap,'filled');
colormap(handles.tSNE_axes, 'copper');

cmap = 1:size(curDmap,1);
if size(curDmap,2) == 3
    scatter3(handles.Dmap_axes, curDmap(:,1),curDmap(:,2),curDmap(:,3),[],cmap,'filled');
else
    scatter(handles.Dmap_axes, curDmap(:,1),curDmap(:,2),[],cmap,'filled');
end
colormap(handles.Dmap_axes, 'copper');


function Load_status_Callback(hObject, eventdata, handles)
% hObject    handle to Load_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Load_status as text
%        str2double(get(hObject,'String')) returns contents of Load_status as a double


% --- Executes during object creation, after setting all properties.
function Load_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Load_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Correspond_maps.
function Correspond_maps_Callback(hObject, eventdata, handles)
% hObject    handle to Correspond_maps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CorrespondMaps();

% --- Executes on button press in Save_dimReduction.
function Save_dimReduction_Callback(hObject, eventdata, handles)
% hObject    handle to Save_dimReduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Pushbutton to save current dimReduction to a .mat files
c = clock;
timetag = ['_' num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5))];
curObj = get(handles.output, 'UserData');
paramtag = ['_' num2str(curObj.tflag) '_' num2str(curObj.locflag), '_', ...
    num2str(curObj.locfactor), '_', num2str(curObj.fd(1)) num2str(curObj.fd(2))];

if curObj.tflag
    methodtag = '_Framewise_';
else
    methodtag = '_Pixelwise_';
end

%save(['dimReduction' methodtag paramtag timetag '.mat'],'curObj', '-v7.3')
uisave('curObj', ['dimReduction' methodtag paramtag timetag '.mat'])
