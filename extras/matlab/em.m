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
function [W, H] = em( V, Nz, M1, M2, MAXITER )
% V - input spectrogram (non-negative matrix)
% Nz - two element vector. Each element specifies how many basis vectors per source
% M1 - real-valued user annotated mask for source 1. Must be the same dimensions as V.
% M2 - real-valued user annotated mask for source 1. Must be the same dimensions as V.
% MAXITER - number of iterations to process

% keep the same random seed
rand('seed',0)

% Get sizes
[Nf,Nt] = size( V );

% make the spectrogram an empirical prob. distribution
V = V ./ sum( V(:));  

% initialize the W and H matrices
W = 1 + rand(Nf, sum(Nz));
W = bsxfun(@rdivide,W,eps+sum(W,1));

H = 1+rand(sum(Nz),Nt);
H = bsxfun(@rdivide,H,eps+sum(H,2));

 % exponentiate real-valued masks or set to 1 if empty
if isempty(M1)
    M1 = 1;
else
    M1 = (exp(-M1)); 
end
if isempty(M2)
    M2 = 1;
else
    M2 = (exp(-M2));
end

inds1 = 1:Nz(1);
inds2 = (1+Nz(1)):sum(Nz);

% psuedo-spectrograms
V1 = V.*M1;
V2 = V.*M2;

% main computation loop
for it = 1:MAXITER
   
    % normalizer
    Z = (W(:, inds1)*H(inds1,:)).*M1 +  (W(:, inds2)*H(inds2,:)).*M2 + eps; 

    % update basis
    W(:,inds1) = W(:,inds1) .*(  ((V1./Z)*H(inds1,:)')); 
    W(:,inds2) = W(:,inds2) .*(  ((V2./Z)*H(inds2,:)'));
    
    % instead of H sum denominator
    W = bsxfun(@rdivide,W,eps+sum(W,1));
    
    % update weights
    H(inds1,:) = H(inds1,:) .* ( (W(:,inds1)'*(V1./Z)));
    H(inds2,:) = H(inds2,:) .* ( (W(:,inds2)'*(V2./Z)));
    
end
 
 