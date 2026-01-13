function varargout = FE_Toolbox(varargin)
% FE_TOOLBOX MATLAB code for FE_Toolbox.fig
%      FE_TOOLBOX, by itself, creates a new FE_TOOLBOX or raises the existing
%      singleton*.
%
%      H = FE_TOOLBOX returns the handle to a new FE_TOOLBOX or the handle to
%      the existing singleton*.
%
%      FE_TOOLBOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FE_TOOLBOX.M with the given input arguments.
%
%      FE_TOOLBOX('Property','Value',...) creates a new FE_TOOLBOX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FE_Toolbox_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FE_Toolbox_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FE_Toolbox

% Last Modified by GUIDE v2.5 11-Jan-2024 22:22:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FE_Toolbox_OpeningFcn, ...
                   'gui_OutputFcn',  @FE_Toolbox_OutputFcn, ...
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


% --- Executes just before FE_Toolbox is made visible.
function FE_Toolbox_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FE_Toolbox (see VARARGIN)

% Choose default command line output for FE_Toolbox
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FE_Toolbox wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FE_Toolbox_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadEEG.
function LoadEEG_Callback(hObject, eventdata, handles)
% hObject    handle to LoadEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.inputfile,handles.inputpath] = uigetfile({'*.set','set Files';'*.*','All Files'},'MultiSelect','on');
guidata(hObject, handles)
      

% --- Executes on button press in output.
function output_Callback(hObject, eventdata, handles)
% hObject    handle to output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_folder_name = uigetdir;
%Update handles with the outDir
handles.outDir = save_folder_name;
guidata(hObject,handles);


% --- Executes on button press in DF.
function DF_Callback(hObject, eventdata, handles)
% hObject    handle to DF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DF

% --- Executes on button press in DFV.
function DFV_Callback(hObject, eventdata, handles)
% hObject    handle to DFV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in DFP.
function DFP_Callback(hObject, eventdata, handles)
% hObject    handle to DFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in RelativePow.
function RelativePow_Callback(hObject, eventdata, handles)
% hObject    handle to RelativePow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in PerChannel.
function PerChannel_Callback(hObject, eventdata, handles)
% hObject    handle to PerChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in PerEpoch.
function PerEpoch_Callback(hObject, eventdata, handles)
% hObject    handle to PerEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in FinalRUN.
function FinalRUN_Callback(hObject, eventdata, handles)
% hObject    handle to FinalRUN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        NumofSubj = length(handles.inputfile);
        if isequal(handles.inputfile,0)
        disp('User selected Cancel');
        else
%         disp(['User selected ', fullfile(handles.path,handles.file)]);
        [ALLEEG EEG CURRENTSET] = eeglab;
        allSetFiles = handles.inputfile;
        targetFolder = handles.inputpath;
        % Start the loop.
        for setIdx = 1:length(allSetFiles)
        % Obtain the file names for loading.
        loadName = allSetFiles(setIdx); % S001-preprocessedafterICA-Epoches.set
        EEG = pop_loadset('filename', loadName, 'filepath', targetFolder);
        EEG = pop_eegfiltnew(EEG, 'locutoff',3,'hicutoff',14);        
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
        end

        handles.data = ALLEEG;
        guidata(hObject, handles)
        end
        
    DF_checkbox = get(handles.DF,'Value');
    DFV_checkbox = get(handles.DFV,'Value');
    DFP_checkbox = get(handles.DFP, 'Value');
    RelativePow_checkbox = get(handles.RelativePow, 'Value');
    PerChannel_checkbox = get(handles.PerChannel, 'Value');
    PerEpoch_checkbox = get(handles.PerEpoch, 'Value');
    
    delta(1) = handles.delta1;
    delta(2) = handles.delta2;
    Theta(1) = handles.Theta1;
    Theta(2) = handles.Theta2;
    PreAlpha(1) = handles.PreAlpha1;
    PreAlpha(2) = handles.PreAlpha2;
    Alpha(1) = handles.Alpha1;
    Alpha(2) = handles.Alpha2;
    Beta(1) = handles.Beta1;
    Beta(2) = handles.Beta2;
    Gamma(1) = handles.Gamma1;
    Gamma(2) = handles.Gamma2;
    C = {delta,Theta,PreAlpha,Alpha,Beta,Gamma};
    ALLEEG = handles.data;
    NumofSubj = size(ALLEEG,2);
    GeneralInfo = struct();
    AllResults = struct();
for subj = 1 : NumofSubj
    GeneralInfo(subj).SubjID = ALLEEG(subj).filename(1:4); 
    GeneralInfo(subj).nbchan = size(ALLEEG(subj).data,1);       % Number of Channels
    GeneralInfo(subj).L = size(ALLEEG(subj).data,2);            % Length of each Epoch
    GeneralInfo(subj).NumEpoch = size(ALLEEG(subj).data,3);     % Number of Epoch
    GeneralInfo(subj).Fs = ALLEEG(subj).srate;                 % Sampling rate
    for channels = 1 : GeneralInfo(subj).nbchan
        for Epochs = 1 : GeneralInfo(subj).NumEpoch
            data = squeeze(ALLEEG(subj).data(channels,:,Epochs));  % EEG signal of 2 second Epoches 
            [spectra, freqs] = PowerSpectrum(data,GeneralInfo(subj).Fs);
            % Dominant Frequency for entire spectrum
            [~, idx_spectra] = max(spectra);
            DF(channels,Epochs) = freqs(idx_spectra);
            % Dominant frequency for specific band
           for Band_indx = 1:length(C)
            Idx = find(freqs>=C{Band_indx}(1) & freqs<=C{Band_indx}(2));    
            [~, idx_] = max(spectra(Idx));
            Freqs  = freqs(Idx);
            DF_V(channels,Epochs,Band_indx) = Freqs(idx_);
            % Mean Relative power for each band
            meanPS(channels,Epochs,Band_indx) = mean(10.^(spectra(Idx)/10));
           end         
        end
       DFV(channels,:) = [std(DF_V(channels,:,1)),std(DF_V(channels,:,2)),std(DF_V(channels,:,3)),...
                        std(DF_V(channels,:,4)),std(DF_V(channels,:,5)),std(DF_V(channels,:,6))];
        % Dominant Frequency Prevelance for Each Channel
        Epoch_DFP = DF(channels,:);
        for Band_idx = 1:length(C)
            Idx1 = find(Epoch_DFP>=C{Band_idx}(1) & Epoch_DFP<=C{Band_idx}(2));    
            DFP(channels,Band_idx) = numel(Idx1)/numel(Epoch_DFP) * 100;
        end
       % Relative Power for each channel 
        for Band_indx = 1:length(C)
            Idx = find(freqs>=C{Band_indx}(1) & freqs<=C{Band_indx}(2));    
            meanPS(channels,Epochs,Band_indx) = mean(10.^(spectra/10));
        end
    end
    AllResults(subj).MeanPS = squeeze(mean(meanPS,2));
    AllResults(subj).DF = DF;
    AllResults(subj).DFvariability = DFV;
    AllResults(subj).DFP = DFP;
    clear meanPS DF DFV DFP
end

for i=1:19
    Rowname{i}=['Channnel',num2str(i)];
end
variablename = { 'Delta', 'Theta', 'PreAlpha','Alpha','Beta','Gamma'};

    if DF_checkbox
      % write your function here for cell diameter
      SUB = length(AllResults);
      allSetFiles = handles.inputfile;
      for j=1:SUB
        Epoch = AllResults(j).DF;
        T = array2table(Epoch, 'RowNames',Rowname);
        filename = strcat('EEG_Results_DF_forallEpochandChannel', '.xlsx');
        Subject_name = char(extractBefore(allSetFiles(j), "."));
        Results_file = [handles.outDir filesep filename];
        writetable(T, Results_file,'WriteRowNames',true, 'Sheet',Subject_name);
      end
     end
     if DFV_checkbox && DF_checkbox
      % write you function here for cell size
      for j=1:SUB
        Band = AllResults(j).DFvariability;
%         Band = DFV;
        T = array2table(Band,'RowNames',Rowname,'VariableNames',variablename);
        filename = strcat('EEG_Results_DFV_Toolbox', '.xlsx');
        Subject_name = char(extractBefore(allSetFiles(j), "."));
        Results_file = [handles.outDir filesep filename];
         writetable(T, Results_file,'WriteRowNames',true, 'Sheet',Subject_name);
      end
%     else
% %         display('Please select the DF check box first');
%         errordlg('Please select the DF check box first.','Error Code I');
%         return;
     end
     if DFP_checkbox && DF_checkbox
      % write you function here for cell size
%       display('Both DFP checkbox is selected');
      for j=1:SUB
        Band = AllResults(j).DFP;
%         Band = DFV;
        T = array2table(round(Band,2),'RowNames',Rowname,'VariableNames',variablename);
        filename = strcat('EEG_Results_DFP_Toolbox', '.xlsx');
        Subject_name = char(extractBefore(allSetFiles(j), "."));
        Results_file = [handles.outDir filesep filename];
         writetable(T, Results_file,'WriteRowNames',true, 'Sheet',Subject_name);
      end      
%     else
% %         display('Please select the DF check box first');
%         errordlg('Please select the DF check box first.','Error Code I');
%         return;
% 
     end

     if RelativePow_checkbox && DF_checkbox
      % write you function here for cell size
%       display('Both RelativePow checkbox is selected');
      for j=1:SUB
          Band = AllResults(j).MeanPS;
%         Band = DFV;
        T = array2table(round(Band,2),'RowNames',Rowname,'VariableNames',variablename);
        filename = strcat('EEG_Results_RelativePow_Toolbox', '.xlsx');
        Subject_name = char(extractBefore(allSetFiles(j), "."));
        Results_file = [handles.outDir filesep filename];
         writetable(T, Results_file,'WriteRowNames',true, 'Sheet',Subject_name);
      end
%     else
% %         display('Please select the DF check box first');
%         errordlg('Please select the DF check box first.','Error Code I');
%         return;
     end
    if PerChannel_checkbox && DF_checkbox
%        display('Both DF and PerChannel checkboxes are Selected');
      for j=1:SUB
        AvgofEpochsforEachChannel = mean(AllResults(j).DF,2);
        T = array2table(AvgofEpochsforEachChannel, 'RowNames',Rowname);
        filename = strcat('EEG_Results_DF_PerChannel', '.xlsx');
        Subject_name = char(extractBefore(allSetFiles(j), "."));
        Results_file = [handles.outDir filesep filename];
        writetable(T, Results_file,'WriteRowNames',true, 'Sheet',Subject_name);
      end
%        else 
% %          display('Please select the DF check box first');  
%         errordlg('Please select the DF check box first.','Error Code I');
%         return;
    end
    if PerEpoch_checkbox && DF_checkbox
      for j=1:SUB
        AvgofChforEpoch = mean(AllResults(j).DF,1);
        T = array2table(AvgofChforEpoch);
        filename = strcat('EEG_Results_DF_PerEpoch', '.xlsx');
        Subject_name = char(extractBefore(allSetFiles(j), "."));
        Results_file = [handles.outDir filesep filename];
        writetable(T, Results_file,'WriteRowNames',true, 'Sheet',Subject_name);
      end
%        else 
% %          display('Please select the DF check box first');  
%         errordlg('Please select the DF check box first.','Error Code I');
%         return;
    end
 


function Deltalow_Callback(hObject, eventdata, handles)
% hObject    handle to Deltalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Deltalow as text
%        str2double(get(hObject,'String')) returns contents of Deltalow as a double
% handles.Deltalow = str2double(get(hObject,'String'));
% if isnan(input)
% handles.Deltalow = 3;
% %     input = str2double(set(handles.Deltalow,'string','3'));
% end
%     handles.Deltalow = input;
%     guidata(hObject,handles);
% S = get(hObject, 'string');
% if isempty(S)
%   S = set(handles.Deltalow,'string','5'); ;
% end
% handles.Deltalow = S;
% guidata(hObject,handles);
handles.delta1 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% edit1 = str2double(get(hObject,'string')); 
% if isnan(edit1) 
% set(handles.edit1,'string','5'); 
% end 


% --- Executes during object creation, after setting all properties.
function Deltalow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Deltalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.delta1 = 3.0;
% disp(handles.delta1)
% set(hObject, 'String', num2str(handles.delta1))
 guidata(hObject, handles);

function Deltahigh_Callback(hObject, eventdata, handles)
% hObject    handle to Deltahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Deltahigh as text
%        str2double(get(hObject,'String')) returns contents of Deltahigh as a double
handles.delta2 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% % input = str2double(get(hObject,'String'));
% handles.Deltahigh = str2double(get(hObject,'String'));
% if isnan(input)
% handles.Deltahigh = 3.5;
% end
%     handles.Deltahigh = input;
%     guidata(hObject,handles);
% S = get(handles.Deltahigh, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Deltahigh = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Deltahigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Deltahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.delta2 = 3.5;
% disp(handles.delta2)
% set(hObject, 'String', num2str(handles.delta2))
 guidata(hObject, handles);



function Thetalow_Callback(hObject, eventdata, handles)
% hObject    handle to Thetalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Thetalow as text
%        str2double(get(hObject,'String')) returns contents of Thetalow as a double
handles.Theta1 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
%   input = 4;
% end
%     handles.Thetalow = input;
%     guidata(hObject,handles);
% S = get(handles.Thetalow, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Thetalow = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Thetalow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Thetalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Theta1 = 4.0;
% disp(handles.Theta1)
% set(hObject, 'String', num2str(handles.Theta1))
 guidata(hObject, handles);



function Thetahigh_Callback(hObject, eventdata, handles)
% hObject    handle to Thetahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Thetahigh as text
%        str2double(get(hObject,'String')) returns contents of Thetahigh as a double
handles.Theta2 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
%    input = 5.5;
% end
%     handles.Thetahigh = input;
%     guidata(hObject,handles);
% S = get(handles.Thetahigh, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Thetahigh = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Thetahigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Thetahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Theta2 = 5.5;
% disp(handles.Theta2)
% set(hObject, 'String', num2str(handles.Theta2))
 guidata(hObject, handles);


function PreAlphalow_Callback(hObject, eventdata, handles)
% hObject    handle to PreAlphalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PreAlphalow as text
%        str2double(get(hObject,'String')) returns contents of PreAlphalow as a double
handles.PreAlpha1 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
%    input = 6;
% end
%     handles.PreAlphalow = input;
%     guidata(hObject,handles);
% S = get(handles.PreAlphalow, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.PreAlphalow = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function PreAlphalow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreAlphalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.PreAlpha1 = 6;
% disp(handles.PreAlpha1)
% set(hObject, 'String', num2str(handles.PreAlpha1))
 guidata(hObject, handles);


function PreAlphahigh_Callback(hObject, eventdata, handles)
% hObject    handle to PreAlphahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PreAlphahigh as text
%        str2double(get(hObject,'String')) returns contents of PreAlphahigh as a double
handles.PreAlpha2 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
% input = 7.5;
% end
%     handles.PreAlphahigh = input;
%     guidata(hObject,handles);
% S = get(handles.PreAlphahigh, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.PreAlphahigh = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function PreAlphahigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreAlphahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.PreAlpha2 = 7.5;
% disp(handles.PreAlpha2)
% set(hObject, 'String', num2str(handles.PreAlpha2))
 guidata(hObject, handles);


function Alphalow_Callback(hObject, eventdata, handles)
% hObject    handle to Alphalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Alphalow as text
%        str2double(get(hObject,'String')) returns contents of Alphalow as a double
handles.Alpha1 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
% input =8;
% end
%     handles.Alphalow = input;
%     guidata(hObject,handles);
% S = get(handles.Alphalow, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Alphalow = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Alphalow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Alphalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Alpha1 = 8;
% disp(handles.Alpha1)
% set(hObject, 'String', num2str(handles.Alpha1))
 guidata(hObject, handles);


function Alphahigh_Callback(hObject, eventdata, handles)
% hObject    handle to Alphahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Alphahigh as text
%        str2double(get(hObject,'String')) returns contents of Alphahigh as a double
handles.Alpha2 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
%   input =  12;
% end
% handles.Alphahigh = input;
%     guidata(hObject,handles);
% 
% S = get(handles.Alphahigh, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Alphahigh = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Alphahigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Alphahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Alpha2 = 12;
% disp(handles.Alpha2)
% set(hObject, 'String', num2str(handles.Alpha2))
 guidata(hObject, handles);


function Betalow_Callback(hObject, eventdata, handles)
% hObject    handle to Betalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Betalow as text
%        str2double(get(hObject,'String')) returns contents of Betalow as a double
handles.Beta1 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
%    input = 13;
% end
%     handles.Betalow = input;
%     guidata(hObject,handles);
% % 
% S = get(handles.Betalow, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Betalow = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Betalow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Betalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Beta1 = 13;
% disp(handles.Beta1)
% set(hObject, 'String', num2str(handles.Beta1))
 guidata(hObject, handles);


function Betahigh_Callback(hObject, eventdata, handles)
% hObject    handle to Betahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Betahigh as text
%        str2double(get(hObject,'String')) returns contents of Betahigh as a double
handles.Beta2 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
%   input = 30;
% end
%     handles.Betahigh = input;
%     guidata(hObject,handles);
% % end
% S = get(handles.Betahigh, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Betahigh = S;
% guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Betahigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Betahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Beta2 = 30;
% disp(handles.Beta2)
% set(hObject, 'String', num2str(handles.Beta2))
 guidata(hObject, handles);


function Gammalow_Callback(hObject, eventdata, handles)
% hObject    handle to Gammalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gammalow as text
%        str2double(get(hObject,'String')) returns contents of Gammalow as a double
handles.Gamma1 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% input = str2double(get(hObject,'String'));
% if isnan(input)
%     input = 30;
% end
% handles.Gammalow = input;
% guidata(hObject,handles);
% S = get(handles.Gammalow, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Gammalow = S;
% guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Gammalow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gammalow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Gamma1 = 30;
%disp(handles.Gamma1)
%set(hObject, 'String', num2str(handles.Gamma1))
 guidata(hObject, handles);


function Gammahigh_Callback(hObject, eventdata, handles)
% hObject    handle to Gammahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gammahigh as text
%        str2double(get(hObject,'String')) returns contents of Gammahigh as a double
handles.Gamma2 = str2double(get(hObject,'String'));
guidata(hObject,handles);
% input = str2double(get(hObject,'String'));
% if isnan(input)
%     input = 45;
% % else
% end
% handles.Gammahigh = input;
% guidata(hObject,handles);
% S = get(handles.Gammahigh, 'string');
% if isempty(S)
%   S = '3';
% end
% handles.Gammahigh = S;
% guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Gammahigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gammahigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Gamma2 = 45;
%disp(handles.Gamma2)
%set(hObject, 'String', num2str(handles.Gamma2))
 guidata(hObject, handles);