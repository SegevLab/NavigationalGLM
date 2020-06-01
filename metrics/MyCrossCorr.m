function [cor,Tout] = MyCrossCorr(A,B)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%T = -100.5:1:100.5;
%Tout = -100:1:100;
T=-1.00005:0.0001:1.00005;
length(T)

Tout=-1:0.0001:1;
length(Tout)
cor=zeros(1,length(T)-1);

for i=1:length(A)
    
        C=B-(A(i));        
        [N,edges] = histcounts(C,T);
        cor=cor+N;
end   
cor=cor/length(B);