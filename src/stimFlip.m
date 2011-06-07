% stim function flips the stimulus and then the mask

function stimFlip(train, delay, l_rect, r_rect, trial, p, bar)

    global exp count
    
    r = p.refresh_rate * .5;
    
    tt = .250;
    
    %disp(num2str(tt));
    d = tt - r;

       
    if train
        trial = 1;
        if count < 8
             d = 2;
        elseif count > 7 && count < 16
            count_ndx = [1.5 1 .66 .33 .11 .09 .07 .05];
            d = count_ndx(count - 7);
        end
    end
    %disp(num2str(delay));

    % VBLTimestamp is a high-precision estimate of when the flip
    %   happened (in system time)
    % StimulusOnsetTime is an estimate of when the stimulus onset
    % FlipTimestamp is a time measurement taken after Flip happens
    % A negative Missed means Flip's deadline was met, positive missed
    % Beampos is the position of the raster beam

    t0 = GetSecs;
    % Flip the stimulus
    [exp.VBLTimestamp(trial, 1) exp.StimulusOnsetTime(trial, 1) ...
        exp.FlipTimestamp(trial, 1) exp.Missed(trial, 1) ...
        exp.Beampos(trial, 1)] = Screen('Flip', p.w0, t0 + .3 + delay);
%     
%     if trial > 1
%         t = toc;
%         disp(num2str(t));
%     end
    
    % if there is intermediate gray (that is, gray between the stimulus and
    % mask) then there is one more flip is required

    Screen('DrawTexture', p.w0, p.ptch_tex);
  
    % Flip the mask
    [exp.VBLTimestamp(trial, 2) exp.StimulusOnsetTime(trial, 2) ...
        exp.FlipTimestamp(trial, 2) exp.Missed(trial, 2) ...
        exp.Beampos(trial, 2)] = Screen('Flip', p.w0, ...
        exp.VBLTimestamp(trial, 1) + d);

end