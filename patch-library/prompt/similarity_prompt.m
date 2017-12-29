function varargout = similarity_prompt(varargin)
%SIMILARITY_PROMPT MATLAB code file for similarity_prompt.fig
%      SIMILARITY_PROMPT, by itself, creates a new SIMILARITY_PROMPT or raises the existing
%      singleton*.
%
%      H = SIMILARITY_PROMPT returns the handle to a new SIMILARITY_PROMPT or the handle to
%      the existing singleton*.
%
%      SIMILARITY_PROMPT('Property','Value',...) creates a new SIMILARITY_PROMPT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to similarity_prompt_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SIMILARITY_PROMPT('CALLBACK') and SIMILARITY_PROMPT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SIMILARITY_PROMPT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help similarity_prompt

% Last Modified by GUIDE v2.5 29-Dec-2017 09:17:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @similarity_prompt_OpeningFcn, ...
                   'gui_OutputFcn',  @similarity_prompt_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before similarity_prompt is made visible.
function similarity_prompt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for similarity_prompt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes similarity_prompt wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% Original xyz, rgb and lab values
% [xyz, rgb, lab, valid] = spectra2color(spectra);


%--------------------------------------------------------------------------
%                                GLOBALS
%--------------------------------------------------------------------------

spectra = varargin{1};
perturbations = varargin{2};

% The number of perturbations for each original spectrum
[n_spectra, n_perturbations, ~] = size(perturbations);


% Constants for the application
consts = [];

consts.spectra = spectra;                       % All original spectra
consts.perturbations = perturbations;           % All possible perturbations
                                                % for each spectrum
                                                
consts.n_spectra = n_spectra;                   % Original spectra count
consts.n_perturbations = n_perturbations;       % Number of perturbation
                                                % per spectrum
                                                
consts.n_pairs = n_spectra * n_perturbations;   % Total number of pairs given


% Global variables that change over time
globals = [];

% Following two will be output variables
globals.ratings = [];                           % They will be returned to
                                                % command line once finished
globals.pairs   = [];                           % It will pair original
                                                % spectra with
                                                % perturbations analyzed

globals.visited = false(n_spectra, n_perturbations);
                                                % Tells if a pair
                                                % spectra/perturbation has
                                                % been visited already
                                                
globals.cur_pair_idx = 0;                       % Index of currently shown
                                                % pair, since you can move
                                                % back and forward


handles.consts  = consts;
handles.globals = globals;

% Generating first state
handles = change_state(handles, 1);

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = similarity_prompt_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


% NOTICE: this is called immediately when the figure is created, so it is
% not a good place where to put output variables, consider a better way to
% specify output variables.
% This is what I wanted to perform, but I cannot do it here
% varargout{1} = handles.ratings;
% varargout{2} = handles.pairs;


% --- Executes when user attempts to close similarity_prompt.
function similarityPrompt_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to similarity_prompt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);                                % TODO: segnala cancellazione


% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles)
% hObject    handle to btnNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = change_state(handles, 1);

guidata(hObject, handles);

% --- Executes on button press in btnBack.
function btnBack_Callback(hObject, eventdata, handles)
% hObject    handle to btnBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = change_state(handles, -1);

guidata(hObject, handles);

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.similarityPrompt);           % TODO: segnala cancellazione

% --- Executes on button press in btnFinish.
function btnFinish_Callback(hObject, eventdata, handles)
% hObject    handle to btnFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.similarityPrompt);           % TODO: segnala risultati


% --- Executes on button press in showDeltaE.
function showDeltaE_Callback(hObject, eventdata, handles)
% hObject    handle to showDeltaE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showDeltaE

handles.state.show_deltaE = not(handles.state.show_deltaE);

update_show_deltaE(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function similarityPrompt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to similarity_prompt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

guidata(hObject, handles);


%--------------------------------------------------------------------------
%------------------------ OTHER FUNCTIONS ---------------------------------
%--------------------------------------------------------------------------


function rating = get_rating(handles)

switch handles.similarityLevel.SelectedObject.Tag
    case 'radio0'
        rating = 0;
    case 'radio1'
        rating = 1;
    case 'radio2'
        rating = 2;
    case 'radio3'
        rating = 3;
    case 'radio4'
        rating = 4;
    case 'radio5'
        rating = 5;
    otherwise
        error('Currently selected object is invalid: %s!', handles.similarityLevel.SelectedObject.tag)
end


function [handles] = save_state(handles)

if handles.globals.cur_pair_idx < 1
    return;
end

rating = get_rating(handles);

idx = handles.globals.cur_pair_idx;

handles.globals.ratings(idx) = rating;
handles.globals.pairs(idx, :) = [handles.state.spectrum_idx, handles.state.pert_idx];
handles.globals.visited(handles.state.spectrum_idx, handles.state.pert_idx) = true;


function idx = rand_index(max_idx)

idx = floor(rand()*max_idx)+1;
if idx > max_idx
    idx = max_idx;
end


function [handles, spectrum_idx, pert_idx] = generate_new_indexes(handles)

how_many_visited = length(handles.globals.ratings);
if how_many_visited >= handles.consts.n_pairs
    return;         % TODO: What to do if there are no other pairs to visit
end

visited = true;
while visited
    spectrum_idx    = rand_index(handles.consts.n_spectra);
    pert_idx        = rand_index(handles.consts.n_perturbations);

    visited         = handles.globals.visited(spectrum_idx, pert_idx);
end


function [handles, valid] = generate_state(handles, spectrum_idx, pert_idx)

handles.state = [];

handles.state.spectrum_idx = spectrum_idx;
handles.state.pert_idx = pert_idx;

[xyz, rgb, lab, valid] = get_current_color(handles);

handles.state.orig = [];
handles.state.orig.xyz = xyz;
handles.state.orig.rgb = rgb;
handles.state.orig.lab = lab;
handles.state.orig.valid = valid;

[xyz, rgb, lab, valid] = get_current_pert_color(handles);

handles.state.pert = [];
handles.state.pert.xyz = xyz;
handles.state.pert.rgb = rgb;
handles.state.pert.lab = lab;
handles.state.pert.valid = valid;
    
valid = handles.state.orig.valid && handles.state.pert.valid;

if not(valid)
    return;
end

handles.state.deltaE = computeDeltaE(handles.state.orig.lab, handles.state.pert.lab);

function obj = cur_selected_object(handles)

if handles.globals.cur_pair_idx > length(handles.globals.ratings)
    obj = handles.radio0;
    return;
end

rating = handles.globals.ratings(handles.globals.cur_pair_idx);
switch rating
    case 0
        obj = handles.radio0;
    case 1
        obj = handles.radio1;
    case 2
        obj = handles.radio2;
    case 3
        obj = handles.radio3;
    case 4
        obj = handles.radio4;
    case 5
        obj = handles.radio5;
    otherwise
        error('Unexpected rayting value: %d', rating);
end

function handles = show_state(handles)
% Hiding deltaE value
handles.state.show_deltaE = false;
handles = update_show_deltaE(handles);

% Showing currently selected radio button
handles.similarityLevel.SelectedObject = cur_selected_object(handles);

% Updating progressRatio
how_many_visited = length(handles.globals.ratings);
progressRatio = how_many_visited / handles.consts.n_pairs * 100;
progressRatio = floor(progressRatio * 10) / 10;
handles.progressRatio.String = strcat(mat2str(progressRatio), '/100');

% Showing current patches
axis(handles.patches);
cla(handles.patches, 'reset');
patch([0 1 1 0], [1 1 0 0], handles.state.orig.rgb.');
patch([1 2 2 1], [1 1 0 0], handles.state.pert.rgb.');
set(handles.patches, 'XTick', []);
set(handles.patches, 'YTick', []);



function [xyz, rgb, lab, valid] = get_current_color(handles)
[xyz, rgb, lab, valid] = spectrum2color(handles.consts.spectra, ...
    handles.state.spectrum_idx);

function [xyz, rgb, lab, valid] = get_current_pert_color(handles)
[xyz, rgb, lab, valid] = pert2color(handles.consts.perturbations, ...
    handles.state.spectrum_idx, handles.state.pert_idx);

function handles = update_show_deltaE(handles)
handles.showDeltaE.Value = handles.state.show_deltaE;

handles.textDeltaE.String = mat2str(handles.state.deltaE, 5);

if(handles.state.show_deltaE)
    handles.textDeltaE.Visible = 'on';
else
    handles.textDeltaE.Visible = 'off';
end

%guidata(hObject, handles);










function handles = change_state(handles, move)

if move == 1
    handles = save_state(handles);
end

% Move can be either 1, 0 or + 1
handles.globals.cur_pair_idx = handles.globals.cur_pair_idx + move;

if handles.globals.cur_pair_idx < 1
    handles.globals.cur_pair_idx = 1;
end

idx = handles.globals.cur_pair_idx;

if idx > length(handles.globals.ratings)
    % Generating a new pair
    valid = false;
    while not(valid)
        [handles, spectrum_idx, pert_idx] = generate_new_indexes(handles);

        [handles, valid] = generate_state(handles, spectrum_idx, pert_idx);
    end
else
    spectrum_idx    = handles.globals.pairs(idx, 1);
    pert_idx        = handles.globals.pairs(idx, 2);
    
    handles = generate_state(handles, spectrum_idx, pert_idx);
end

handles = show_state(handles);

function deltaE = computeDeltaE(lab1, lab2)
deltaE = norm(lab1 - lab2);
