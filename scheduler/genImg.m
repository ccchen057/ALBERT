
fig = figure

A = csvread('packed_result.csv');
rectangle('Position', [0,0,18675,48]);
%hold on
N = size(A, 1)



set(gcf,'Units', 'centimeters', 'position', [5 5 50 50]);
xlabel('Time(sec)')
ylabel('Resource(NodeID)') 
set(gca, 'fontsize', 16)
set(gca, 'ytick', 0:6:48)
xlim([0 10000])
ylim([0 48])

last = 0

for i = 1:N
    
    hold on
    
    data = A(i,:)
    
    if last ~= data(1)
        rand_num = rand(1, 3)
        saveas(fig, ['scheduler_' sprintf('%03d',last) '.png'], 'png')
    end
    last = data(1)
    
    xp = data(2) / 1000;
    yp = data(3);
    w = data(4) / 1000;
    h = data(5);
    
    x = [ xp xp xp+w xp+w]
    y = [ yp yp+h yp+h yp]
    h = fill(x, y, rand_num)
    set(h, 'LineWidth', 1)
    
    hold off
end
