function [cor] = MyCrossCorrMS(A,B, T)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%T = -505.5:10:505.5;
%Tout = -500:10:500;
%T=-1.00005:0.0001:1.00005;


%Tout=-1:0.0001:1;
cor=zeros(1,length(T)-1);

for i=1:length(A)
        C=B-A(i);        
        [N,edges] = histcounts(C,T);
        cor=cor+N;
end   
cor=cor/length(B);
cor(cor > 1) = 1;
