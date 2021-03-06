function SRLoadOptions(handles)
global SR scratchPath  %#ok<NUSED>

    dlg_title = 'Update Load Options';
    num_lines = 1;

    default_opts = ...
        {SR{handles.gui_number}.LoadOps.pathin,...
        CSL2str(SR{handles.gui_number}.LoadOps.chns),...
        SR{handles.gui_number}.LoadOps.warpfile,...
        num2str(SR{handles.gui_number}.LoadOps.warpD),...
        num2str(SR{handles.gui_number}.LoadOps.correctDrift),...
        SR{handles.gui_number}.LoadOps.chnOrder,...
        }';
    prompt = ...
        {'Data Folder',...
        'Channel Names (must match names in chromewarp)',...
        'warpfile',...
        'warp dimension',...
        'Correct global drift (files must be loaded in order acquired)',...
        'Order acquired (see display channels box for order listed)',...
        };
try    
opts = inputdlg(prompt,dlg_title,num_lines,default_opts);
catch er  % if values get really screwed up, start again
    disp(er.message); 
    SR{handles.gui_number}.LoadOps.warpD = 3; % set to 0 for no chromatic warp
    SR{handles.gui_number}.LoadOps.warpfile = ''; % can leave blank if no chromatic warp
    SR{handles.gui_number}.LoadOps.chns = {''};% {'750','647','561','488'};
    SR{handles.gui_number}.LoadOps.pathin = '';
    SR{handles.gui_number}.LoadOps.correctDrift = true;
    SR{handles.gui_number}.LoadOps.chnOrder = '[1:end]'; 
    SR{handles.gui_number}.LoadOps.sourceroot = '';
    SR{handles.gui_number}.LoadOps.bintype = '_alist.bin';
    SR{handles.gui_number}.LoadOps.chnFlag = {'750','647','561','488'};  
    SR{handles.gui_number}.LoadOps.dataset = 0;
        default_opts = ...
        {SR{handles.gui_number}.LoadOps.pathin,...
        CSL2str(SR{handles.gui_number}.LoadOps.chns),...
        SR{handles.gui_number}.LoadOps.warpfile,...
        num2str(SR{handles.gui_number}.LoadOps.warpD),...
        num2str(SR{handles.gui_number}.LoadOps.correctDrift),...
        SR{handles.gui_number}.LoadOps.chnOrder,...
        }';
    opts = inputdlg(prompt,dlg_title,num_lines,default_opts);
end

if ~isempty(opts)
    SR{handles.gui_number}.LoadOps.pathin = opts{1};
    SR{handles.gui_number}.LoadOps.chns = parseCSL(opts{2});
    SR{handles.gui_number}.LoadOps.warpfile = opts{3};
    SR{handles.gui_number}.LoadOps.warpD = str2double(opts{4});
    SR{handles.gui_number}.LoadOps.correctDrift = logical(str2double(opts{5}));
    SR{handles.gui_number}.LoadOps.chnOrder = opts{6};      
end