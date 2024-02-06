% Given onset and offset samples, it creates an alternating 1-0 signal
% (starting from on state (1)) of 1001 samples.
% It return a "boolean" signal, so values 0-1 but in double format.

function sig = BooleanSignalCreator(meanOn,meanOff)

if iscolumn(meanOn)
    meanOn = meanOn';
end
if iscolumn(meanOff)
    meanOff = meanOff';
end

changeEvents = sort([meanOn, meanOff]);

edges = [0, changeEvents, 1001];

counter = histcounts(1:1001, edges);

sig = zeros(1, 1001);

idx = 1;
for i = 1:length(counter)
    sig(idx:(idx + counter(i) - 1)) = mod(i, 2);
    idx = idx + counter(i);
end

end

