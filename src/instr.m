function instrN(w0)
    
    instr_txt = ...
        sprintf('%s\n\n', ...
        'Welcome to the speed-of-sight experiment.',  ...
        'You will be presented with a series of image pairs.', ...
        'A target will always be presented in either the left or right image.', ...  
        'Both images will be followed by a mask.', ...  
        'In this experiment you will be looking for a specific number.', ...
        'At the beginning of each block you will be prompted with the number of the target.', ...
        'Please indicate--as quickly and accurately as possible--whether or not a target was presented.', ... 
        'Press the Space Bar to advance.');
    
    DrawFormattedText(w0, instr_txt, 'center', 'center');
    Screen('Flip',w0);
    
    spacePress;
    
    pract_txt = sprintf('%s\n\n', ...
        'Respond by pressing Right Shift if the image on the right was the target,', ...
        'and Left Shift if the image on the Left was the target.', ...
        'If, for any reason, you need to pause or exit the experiment press the Escape key.', ...
        'For a reminder of the key mappings press i.', ... 
        'You will start with a set of practice images.', ...  
        'You may end the training at any time by pressing t.', ...
        'If you have any questions please ask them now.', ...
        'Press the Space Bar to begin.');
    
    DrawFormattedText(w0, pract_txt, 'center', 'center');
    Screen('Flip',w0);
    
    WaitSecs(.2);

    spacePress;
    
end