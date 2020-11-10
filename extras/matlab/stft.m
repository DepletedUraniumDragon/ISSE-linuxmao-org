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
function y = stft( x, FFTSIZE, HOPSIZE, window)
% Short-time Fourier transform
%
%  function f = stft( x, FFTSIZE, HOPSIZE, window)
%  x - input time signal (must be a vector), or complex matrix pectrogram (0-fs/2)
%  FFTSIZE - size of the FFT
%  HOPSIZE - hop size in samples
%  window - window vector
%  y   complex STFT output (0-fs/2), or time signal reconstructed


if isreal(x)
    y = forwardstft(x(:), FFTSIZE, HOPSIZE, window);
else
    y = inversestft(x, FFTSIZE, HOPSIZE, window);
end

function y = forwardstft(x, FFTSIZE, HOPSIZE, window)
   
    s = buffer(x, FFTSIZE, FFTSIZE-HOPSIZE);
    
    % apply window
    s = s.*repmat(window, 1, size(s,2));

	% FFT of buffer matrix
	y = fft(s, FFTSIZE);

	% positive frequencies
	y = y(1:end/2+1,:);

    
function y = inversestft(X, FFTSIZE, HOPSIZE, window)

    % inverse fft
    X = real( ifft( [X; conj( X(end-1:-1:2,:))]));
    
    % Overlap and add
    y = zeros((size(X,2)-1)*HOPSIZE+FFTSIZE, 1);
	for i = 1:size( X,2)
        y((i-1)*HOPSIZE+(1:FFTSIZE)) = y((i-1)*HOPSIZE+(1:FFTSIZE)) + X(:,i);
	end

	% overlap rescale
	y = y / (FFTSIZE/HOPSIZE);
    
    % chop the front zero padding
    y(1:(FFTSIZE-HOPSIZE)) = [];    
    