function Threshold=findthreshold(m,pt)
MAX=max(m);
for Threshold=0:0.001:MAX
p = numel(m(m<Threshold))/numel(m);
if p>=pt
break;
end
end
end
