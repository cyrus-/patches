% patchExp is the main function for the patches experiment.  
% Call this function to begin the experiment. 

function patchExp()
    global exp_struct 
    
    eye_tracking = 0;
    sound = 0;
        
    % w0 is the window pointer
    % w0_rect is a 4-element array containing the x,y coordinates of the
    %   upper left and lower right corners of the screen   n   
    % w,h are the x,y midpoints of the screen
    % exp_struct is a data structure containing relevant experimental values
    % these functions will not work because of a problem with java
    % ListenChar(2);              % prevents key stokes from displaying
    % KbName('UnifyKeyNames');    % Switches internal naming scheme to
    % MacOS-X naming scheme   
    
    [button answer] = getInfoOctave;    
    
    ptb_struct = struct(); % psych toolbox related parameters

    % Set up screen
    width = 1024;
    height = 768;
    top = 0;
    left = 1680;
    bottom = top + height;
    right = left + width;
    
    Screen('Preference','SkipSyncTests', 2);
    maxScreen = max(Screen('Screens'));
    [ptb_struct.w0, ptb_struct.w0_rect] = ...
	Screen('OpenWindow',maxScreen, [], [left top right bottom]);
    
    
    ptb_struct.screen_xC = ptb_struct.w0_rect(3)/2;          % x midpoint
    ptb_struct.screen_yC = ptb_struct.w0_rect(4)/2;          % y midpoint

    %fixation coordinates
    xlen = 25;
    ptb_struct.fix_xy = ...
	[ptb_struct.screen_xC, ptb_struct.screen_xC, ptb_struct.screen_xC+xlen, ptb_struct.screen_xC-xlen; ...
	 ptb_struct.screen_yC+xlen, ptb_struct.screen_yC-xlen, ptb_struct.screen_yC, ptb_struct.screen_yC];      

    Screen('TextSize', ptb_struct.w0, 20);
    ptb_struct.refresh_rate = Screen('GetFlipInterval',ptb_struct.w0);
    
    % Set up experiment
    blocks = 10;
    trials = 50;
    total = blocks * trials;
    n_x_factors = 2;
    n_flips = 3; % num of flips per trial

    exp_struct = setExpValues(answer, total, n_x_factors, n_flips);
    exp_struct.ptb_struct = ptb_struct;
    exp_struct.official_flag = strcmp(button,'Yes');
    exp_struct.blocks = blocks;
    exp_struct.trials = trials;
    exp_struct.total = total;
    exp_struct.delay = 0.1;
    exp_struct.save_mode = true;
    
    % Experiment-specific additions to trial_struct
    exp_struct.trial_struct.patch_struct = cell(total, 1);
        
    exp_struct.path_local = [ pwd '/' ]; % local path
    src_ndx = strfind(exp_struct.path_local, 'src');
    exp_struct.path_parent = exp_struct.path_local(1:src_ndx-1);

    % set file name for storing experimental data
    exp_struct.path_results = ...
	[exp_struct.path_parent, 'results/'];
    if ~exist(exp_struct.path_results,'dir')
      error(['~exist(): ', exp_struct.path_results]);
    end
    
    if exp_struct.official_flag
      exp_struct.path_exp = [exp_struct.path_results, 'official/'];
    else
      exp_struct.path_exp = [exp_struct.path_results, 'tmp/'];
    end
    exp_struct.exp_file = ...
	    [exp_struct.path_exp, num2str(round(exp_struct.seed))];

    % setup images
    % assume all paths relative to current directory
    exp_struct.path_data = [exp_struct.path_parent, 'data/']; 
    if ~exist(exp_struct.path_data,'dir')
      error(['~exist(): ', exp_struct.path_data]);
    end
    
    exp_struct.path_stim = [exp_struct.path_data, 'ALLSTIMULI/']; 
    if ~exist(exp_struct.path_stim,'dir')
      error(['~exist(): ', exp_struct.path_stim]);
    end
    exp_struct.imgs  = dir([exp_struct.path_stim, '*.jpeg']);
    
    % Load patchData
    load([exp_struct.path_data 'patchData.mat'])
    exp_struct.patch_data = patchData;
    
    % Contrast match images
    contrast_match_flag = 0; % If 0, loads medPI.mat from data directory
    [lft_ndx rgt_ndx] = ...
	contrastMatch(exp_struct, contrast_match_flag);
    
    exp_struct.trial_struct.lft_ndx = lft_ndx;
    exp_struct.trial_struct.rgt_ndx = rgt_ndx;

    % set up sound
    exp_struct.sound = sound;
    if sound
        exp_struct.ding = wavread([exp_struct.path_parent 'ding.wav']);
        exp_struct.buzzer = wavread([exp_struct.path_parent 'buzzer.wav']);
        exp_struct.ding_rate = 11025;
        exp_struct.buzzer_rate = 44100;
    end
    
    % set up eye tracking
    exp_struct.eye_tracking = eye_tracking;
    if eye_tracking
        exp_struct.ptb_struct.el = EyelinkInitDefaults(exp_struct.ptb_struct.w0);
        if ~EyelinkInit();
            error('Eyelink Init aborted.');
            cleanup;
            return;
        end
        
        Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
        Eyelink('Openfile', 'demo.edf');
        EyelinkDoTrackerSetup(exp_struct.ptb_struct.el);
        EyelinkDoDriftCorrection(exp_struct.ptb_struct.el);  
        WaitSecs(0.1);
        Eyelink('StartRecording');

        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
        if eye_used == exp_struct.ptb_struct.el.BINOCULAR; % if both eyes are tracked
            eye_used = exp_struct.ptb_struct.el.LEFT_EYE; % use left eye
        end
        exp_struct.eye_used = eye_used;
        
    end
    
    % start experiment
    instr(exp_struct.ptb_struct.w0);
    experiment();
    Screen('CloseAll');
end  


function exp_struct = setExpValues(answer, tot, n_x_factors, n_flips)    

    trial_struct = struct();
    trial_struct.target_ndx = zeros(tot, 1);
    trial_struct.lft_ndx = zeros(tot, 1);
    trial_struct.rgt_ndx = zeros(tot, 1);
    trial_struct.choice = zeros(tot, 1);
    trial_struct.confidence = zeros(tot, 1);
    trial_struct.correct = zeros(tot, 1);
    trial_struct.x_factors = zeros(tot, n_x_factors);
    % draw the target patch from the left or right image with equal
    % probability
    % random number generator
    seed = sum(100*clock);
    rand('twister', seed);
    trial_struct.target_flag = Shuffle([ones(tot/2,1); zeros(tot/2,1)]);

    exp_struct = struct( ...
        'vision', answer{1}, ...
        'age', answer{2}, ...
        'gender', answer{3}, ...
        'handedness', answer{4}, ...
        'participation', answer{5}, ...
        'familiarity', answer{6}, ...
        'response_time', zeros(tot, 2), ...
        'VBLTimestamp', zeros(tot, n_flips), ...
        'StimulusOnsetTime', zeros(tot, n_flips), ...
        'FlipTimestamp', zeros(tot, n_flips), ...
        'Missed', zeros(tot, n_flips), ...
        'Beampos', zeros(tot, n_flips), ...
        'trial_struct', trial_struct, ...
        'seed', seed);
    
end


%% works only in matlab
function [button answer] = getInfo()
  %% 2nd arg == title, 3rd ard == default
  button = questdlg('Is this an official experiment?','official','No');
    if strcmp(button, 'Cancel');
      Screen('CloseAll');
      error('Cancelled')
    end

    prompt = {'Do you have normal or corrected-to-normal vision?', ...
	      'What is your age?', 'What is your gender?', ...
	      'Are you right handed or left handed?' ...
	      'How many times have you participated?  Enter 0 if this is your first time.', ...
	      'Are you familiar with this image set?'};
    dlg_title = 'Input';
    num_lines = 1;
    %def = {'20','hsv'};
    answer = inputdlg(prompt,dlg_title,num_lines);
end

