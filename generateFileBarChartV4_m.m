function generateFileBarChartV4_m(sampleSize, initialDate, finalDate)

    % Get the list of files in the current working directory
    files = dir('*.m');

    % Exclude files starting with a dot and those having a name consisting of only a dot
    files = files(~startsWith({files.name}, '.') & ~strcmp({files.name}, '.'));

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
    dateCategories = datetime(startDate:sampleSize:endDate, 'ConvertFrom', 'datenum', 'Format', 'MM/dd/yy');

    % Initialize variables to store aggregated size for each extension
    totalSizes = zeros(length(uniqueExtensions), length(dateCategories));

    % Manually define distinct colors for each file type
    distinctColors = lines(length(uniqueExtensions));

    % Create categorical variable for file extensions
    extensionCategories = categorical(uniqueExtensions);

    % Iterate through each file extension
    for j = 1:length(uniqueExtensions)
        extension = uniqueExtensions{j};

        % Iterate through each sample
        for k = 1:length(dateCategories)
            % Find files with the current extension and within the specified date range
            extensionIndex = find(strcmp(fileExtensions, extension) & floor(fileDates) >= datenum(dateCategories(k)) & floor(fileDates) < datenum(dateCategories(k) + days(sampleSize)));

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
    h = bar(dateCategories, totalSizes', 'stacked');

    % Set colors
    for i = 1:length(h)
        h(i).FaceColor = distinctColors(mod(i-1, length(distinctColors)) + 1, :);
    end

    xlabel('Dates');
    ylabel('Total File Size (KB)');
    title(['Total File Size Distribution from ' datestr(startDate, 'mm/dd/yy') ' to ' datestr(endDate, 'mm/dd/yy')]);

    % Add legends for file extensions
    legend(extensionCategories, 'Location', 'west', 'Orientation', 'vertical');

end

