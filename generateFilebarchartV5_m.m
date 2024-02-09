function generateFilebarchartV5_m(sampleSize, initialDate, finalDate)

    % Get the list of files in the current working directory
    files = dir('*.m');

    % Exclude files starting with a dot and those having a name consisting of only a dot
    files = files(~strncmp({files.name}, '.', 1) & ~strcmp({files.name}, '.'));

    % Sort files based on creation date (year and day of the year)
    [~, sortedIndices] = sort([files.datenum]);
    files = files(sortedIndices);

    % Extract file information
    fileDates = [files.datenum]; % Use the 'datenum' field for file dates
    fileSizes = [files.bytes] / 1024; % Convert bytes to kilobytes

    % Use a cell array to store file names
    fileNames = {files.name};

    % Extract file extensions explicitly
    fileExtensions = cell(size(fileNames));
    for i = 1:length(fileNames)
        [~, ~, fileExtensions{i}] = fileparts(fileNames{i});
    end

    % Identify unique file extensions
    uniqueExtensions = unique(fileExtensions);

    % Define the date range based on inputs
    startDate = max(datenum(initialDate), min(fileDates)); % Ensure startDate is not earlier than the first file date
    endDate = min(datenum(finalDate), floor(now)); % Ensure endDate is not later than the current date

    % Generate dates with the specified sample size
    dateCategories = datestr(startDate:sampleSize:endDate, 'mm/dd/yy');
    dateCategories = cellstr(dateCategories);

    % Initialize variables to store aggregated size for each extension
    totalSizes = zeros(length(uniqueExtensions), length(dateCategories));

    % Manually define distinct colors for each file type
    distinctColors = lines(length(uniqueExtensions));

    % Create cell array for file extensions
    extensionCategories = cell(1, length(uniqueExtensions));
    extensionCategories(:) = uniqueExtensions;

    % Iterate through each file extension
    for j = 1:length(uniqueExtensions)
        extension = uniqueExtensions{j};

        % Iterate through each sample
        for k = 1:length(dateCategories)
            % Find files with the current extension and within the specified date range
            extensionIndex = find(strcmp(fileExtensions, extension) & floor(fileDates) >= datenum(dateCategories{k}) & floor(fileDates) < datenum(dateCategories{k}) + sampleSize);

            % Check if there are files with the current extension
            if ~isempty(extensionIndex)
                % Extract sizes for the current extension within the current sample
                extensionSizes = fileSizes(extensionIndex);

                % Accumulate and stack file sizes
                totalSizes(j, k) = sum(extensionSizes);
            end
        end
    end

    % Create a bar graph for each file extension on the same plot
    figure;
    bar(totalSizes', 'stacked');

    % Set colors
    colormap(distinctColors);

    % Set x-axis tick locations and labels
    xticklocations = linspace(1, length(dateCategories), length(dateCategories));
    set(gca, 'XTick', xticklocations);

   % Rotate x-axis tick labels
    text(xticklocations, repmat(-0.1, 1, length(xticklocations)), dateCategories, ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Rotation', 45);

   % Remove numeric tick labels
    set(gca, 'XTickLabel', []);

    % Calculate the center position dynamically
    xlabelText = 'Dates';
    xlabelYPosition = -0.1; % Adjust this value to set the distance downward
    % Set xlabel at a fixed position
    xlabel(xlabelText, 'Units', 'normalized', 'Position', [0.5, xlabelYPosition, 0]);
    ylabel('Total File Size (KB)');
    title(['Total File Size Distribution from ' datestr(startDate, 'mm/dd/yy') ' to ' datestr(endDate, 'mm/dd/yy')]);

    % Add legends for file extensions
    legend(extensionCategories, 'Location', 'northoutside', 'Orientation', 'horizontal');

    % Adjust x-axis limits to include the final date
    xlim([0.5, length(dateCategories) + 0.5]);

end

