function ObjVal = nntrainxor221b(Chrom,net)
[Nind Nvar]=size(Chrom);
load data2
inp=2;
out=1;
hidden=20;
for i=1:Nind
  
x=Chrom(i,:);

    iw = reshape(x(1:hidden*inp),hidden,inp);
    b1 = reshape(x(hidden*inp+1:hidden*inp+hidden),hidden,1);
    lw = reshape(x(hidden*inp+hidden+1:hidden*inp+hidden+hidden*out),out,hidden);
    b2 = reshape(x(hidden*inp+hidden+hidden*out+1:hidden*inp+hidden+hidden*out+out),out,1);
 net.IW{1,1}=iw;
net.LW{2,1}=lw;
net.b{1}=b1;
net.b{2}=b2;
y=sim(net,X);
    ObjVal(i)=mse(YY-y);
end


