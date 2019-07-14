%% Start you GUI here
classdef start_gui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        Image               matlab.ui.control.Image
        Image2              matlab.ui.control.Image
        ChallengeButton     matlab.ui.control.Button
        UITable             matlab.ui.control.Table
        UITable_2           matlab.ui.control.Table
        PLabel              matlab.ui.control.Label
        PTextArea           matlab.ui.control.TextArea
        UnitestButton       matlab.ui.control.Button
        UIAxes              matlab.ui.control.UIAxes
        ChooseFolderButton  matlab.ui.control.Button
        UITable2            matlab.ui.control.Table
    end

    
    properties (Access = public)
        SourceImg; 
        D;
        G;
        R;
        T;
        p;
    end
        % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function StartupFcn(app)

        end

        % Button pushed function: ChallengeButton
        function ChallengeButtonPushed(app, event)
            [app.D, app.R, app.T, app.p]= challenge(app.SourceImg);
            
            %Update the Values
            app.UITable.Data=app.T;
            app.UITable_2.Data=app.R;
            app.PTextArea.Value=string(app.p);
            
            %Display Disparity Map
            %disp_map=imread(app.D);
            imshow(uint8(app.D),[],'Parent',app.UIAxes);
            colormap(app.UIAxes, 'jet' );
            
            
        end

        % Display data changed function: UITable
        function UITableDisplayDataChanged(app, event)
            
            newDisplayData = app.UITable.Data;
            f = uifigure;
            app.UITable = uitable(f,'Data',newDisplayData);
            
        end

        % Display data changed function: UITable_2
        function UITable_2DisplayDataChanged(app, event)
            
            newDisplayData = app.UITable_2.Data;
            f = uifigure;
            app.UITable = uitable(f,'Data',newDisplayData);
 
        end

        % Value changed function: PTextArea
        function PTextAreaValueChanged(app, event)
            value = app.PTextArea.Value;
            uf = uifigure;
            tarea = uitextarea(uf);
            tarea.Value = value;  
            
        end

        % Button pushed function: UnitestButton
        function UnitestButtonPushed(app, event)
            rt = unittest();
            app.UITable2.Data = rt;
            
        end

        % Button pushed function: ChooseFolderButton
        function ChooseFolderButtonPushed(app, event)
            selpath = uigetdir;
            app.SourceImg= selpath;
            addpath(selpath);
            app.Image.ImageSource=strcat(app.SourceImg,"\im0.png");
            app.Image2.ImageSource=strcat(app.SourceImg,"\im1.png");

            
        end

        % Callback function
        function TextAreaValueChanged(app, event)
            value = app.TextArea.Value;
            uf = uifigure;
            tarea = uitextarea(uf);
            tarea.Value = value;  
        end

        % Callback function
        function UITable2CellEdit(app, event)
            indices = event.Indices;
            newData = event.NewData;
            
        end

        % Display data changed function: UITable2
        function UITable2DisplayDataChanged(app, event)
            newDisplayData = app.UITable2.DisplayData;
            f = uifigure;
            app.UITable = uitable(f,'Data',newDisplayData);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1190 561];
            app.UIFigure.Name = 'UI Figure';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.Image.Position = [29 202 240 157];
            app.Image.ImageSource = 'im0.png';

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [29 20 238 157];
            app.Image2.ImageSource = 'im1.png';

            % Create ChallengeButton
            app.ChallengeButton = uibutton(app.UIFigure, 'push');
            app.ChallengeButton.ButtonPushedFcn = createCallbackFcn(app, @ChallengeButtonPushed, true);
            app.ChallengeButton.Position = [66 454 148 22];
            app.ChallengeButton.Text = 'Challenge';

            % Create UITable
            app.UITable = uitable(app.UIFigure);
            app.UITable.ColumnName = {'T'};
            app.UITable.RowName = {};
            app.UITable.DisplayDataChangedFcn = createCallbackFcn(app, @UITableDisplayDataChanged, true);
            app.UITable.Position = [914 416 108 117];

            % Create UITable_2
            app.UITable_2 = uitable(app.UIFigure);
            app.UITable_2.ColumnName = {''; 'R'; ''};
            app.UITable_2.RowName = {};
            app.UITable_2.DisplayDataChangedFcn = createCallbackFcn(app, @UITable_2DisplayDataChanged, true);
            app.UITable_2.Position = [849 271 238 137];

            % Create PLabel
            app.PLabel = uilabel(app.UIFigure);
            app.PLabel.HorizontalAlignment = 'right';
            app.PLabel.Position = [947 237 25 22];
            app.PLabel.Text = 'P';

            % Create PTextArea
            app.PTextArea = uitextarea(app.UIFigure);
            app.PTextArea.ValueChangedFcn = createCallbackFcn(app, @PTextAreaValueChanged, true);
            app.PTextArea.Position = [914 202 113 36];

            % Create UnitestButton
            app.UnitestButton = uibutton(app.UIFigure, 'push');
            app.UnitestButton.ButtonPushedFcn = createCallbackFcn(app, @UnitestButtonPushed, true);
            app.UnitestButton.Position = [66 399 148 22];
            app.UnitestButton.Text = 'Unitest';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Disparity Map')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.Position = [288 192 504 359];

            % Create ChooseFolderButton
            app.ChooseFolderButton = uibutton(app.UIFigure, 'push');
            app.ChooseFolderButton.ButtonPushedFcn = createCallbackFcn(app, @ChooseFolderButtonPushed, true);
            app.ChooseFolderButton.Position = [66 511 148 22];
            app.ChooseFolderButton.Text = 'Choose Folder';

            % Create UITable2
            app.UITable2 = uitable(app.UIFigure);
            app.UITable2.ColumnName = {'Name'; 'Passed'; 'Failed'; 'Incomple'; 'Duration'; 'Reason(s)'};
            app.UITable2.RowName = {};
            app.UITable2.DisplayDataChangedFcn = createCallbackFcn(app, @UITable2DisplayDataChanged, true);
            app.UITable2.Position = [310 18 515 175];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = start_gui

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @StartupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end