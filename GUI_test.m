classdef GUI_test < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        Image                         matlab.ui.control.Image
        Image2                        matlab.ui.control.Image
        DisparityMapButton            matlab.ui.control.Button
        UITable                       matlab.ui.control.Table
        UITable_2                     matlab.ui.control.Table
        PTextAreaLabel                matlab.ui.control.Label
        PTextArea                     matlab.ui.control.TextArea
        RLabel                        matlab.ui.control.Label
        TLabel                        matlab.ui.control.Label
        InputSubfolderEditFieldLabel  matlab.ui.control.Label
        InputSubfolderEditField       matlab.ui.control.EditField
        UnitestButton                 matlab.ui.control.Button
        UIAxes                        matlab.ui.control.UIAxes
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
            addpath('data');
            app.Image.ImageSource="motorcycle/im0.png";
            app.Image2.ImageSource="motorcycle/im1.png";
            app.SourceImg = 'motorcycle';
            
        end

        % Callback function
        function PretestedSubfoldersButtonGroupSelectionChanged(app, event)
            selectedButton = app.PretestedSubfoldersButtonGroup.SelectedObject;
            if selectedButton == app.MotorcycleButton
                %Motorcycle
                app.Image.ImageSource="motorcycle/im0.png";
                app.Image2.ImageSource="motorcycle/im1.png";
                app.SourceImg = 'motorcycle';

            elseif selectedButton == app.SwordButton
                %Sword
                app.Image.ImageSource="sword/im0.png";
                app.Image2.ImageSource="sword/im1.png";
                app.SourceImg = 'sword';

            elseif selectedButton == app.PlaygroundButton
                %Playground
                app.Image.ImageSource="playground/im0.png";
                app.Image2.ImageSource="playground/im1.png";
                app.SourceImg = 'playground';

            elseif selectedButton == app.TerraceButton
                %Terrace
                app.Image.ImageSource="terrace/im0.png";
                app.Image2.ImageSource="terrace/im1.png";
                app.SourceImg = 'terrace';

            end
            
        end

        % Image clicked function: Image
        function ImageClicked(app, event)
            
        end

        % Button pushed function: DisparityMapButton
        function DisparityMapButtonPushed(app, event)
            %[app.D,disp_right,IL,IR] = calculateDisparityMap(IL,IR, ...
            %max_image_size,max_disp_factor,window_size_factor,gauss_filt,outlier_compensation,median_filter)
           
            [app.D, app.R, app.T]=disparity_map(strcat("data/",app.SourceImg));
            app.UITable.Data=app.T;
            app.UITable_2.Data=app.R;
            %disp_map=imread(app.D);
            imshow(app.D,'Parent',app.UIAxes);
            colormap(app.UIAxes, 'jet' );
            %set(app.UIAxes,'visible','off');
            
                        
            
            
            %Muss noch verstehen was G ist?
            app.G = disparityshow(app.Image.ImageSource);
            app.p=verify_dmap(app.D,app.G);
            app.PTextArea.Value=string(app.p);
            
            
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

        % Value changed function: InputSubfolderEditField
        function InputSubfolderEditFieldValueChanged(app, event)
            value = app.InputSubfolderEditField.Value;
            app.SourceImg=string(value);
            Source1= strcat("data/",app.SourceImg,"/im0.png");
            Source2= strcat("data/",app.SourceImg,"/im1.png");
            app.Image.ImageSource=Source1;
            app.Image2.ImageSource=Source2;

            
            
        end

        % Button pushed function: UnitestButton
        function UnitestButtonPushed(app, event)
            runtests('unittests');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 788 548];
            app.UIFigure.Name = 'UI Figure';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.Image.Position = [255 377 240 157];
            app.Image.ImageSource = 'im0.png';

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [511 377 238 157];
            app.Image2.ImageSource = 'im1.png';

            % Create DisparityMapButton
            app.DisparityMapButton = uibutton(app.UIFigure, 'push');
            app.DisparityMapButton.ButtonPushedFcn = createCallbackFcn(app, @DisparityMapButtonPushed, true);
            app.DisparityMapButton.Position = [110 468 100 22];
            app.DisparityMapButton.Text = 'Disparity Map';

            % Create UITable
            app.UITable = uitable(app.UIFigure);
            app.UITable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'};
            app.UITable.RowName = {};
            app.UITable.DisplayDataChangedFcn = createCallbackFcn(app, @UITableDisplayDataChanged, true);
            app.UITable.Position = [510 222 238 137];

            % Create UITable_2
            app.UITable_2 = uitable(app.UIFigure);
            app.UITable_2.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'};
            app.UITable_2.RowName = {};
            app.UITable_2.DisplayDataChangedFcn = createCallbackFcn(app, @UITable_2DisplayDataChanged, true);
            app.UITable_2.Position = [511 86 238 137];

            % Create PTextAreaLabel
            app.PTextAreaLabel = uilabel(app.UIFigure);
            app.PTextAreaLabel.HorizontalAlignment = 'right';
            app.PTextAreaLabel.Position = [470 54 25 22];
            app.PTextAreaLabel.Text = 'P:';

            % Create PTextArea
            app.PTextArea = uitextarea(app.UIFigure);
            app.PTextArea.ValueChangedFcn = createCallbackFcn(app, @PTextAreaValueChanged, true);
            app.PTextArea.Position = [510 42 239 36];

            % Create RLabel
            app.RLabel = uilabel(app.UIFigure);
            app.RLabel.Position = [483 193 12 22];
            app.RLabel.Text = 'R:';

            % Create TLabel
            app.TLabel = uilabel(app.UIFigure);
            app.TLabel.Position = [483 311 25 22];
            app.TLabel.Text = 'T:';

            % Create InputSubfolderEditFieldLabel
            app.InputSubfolderEditFieldLabel = uilabel(app.UIFigure);
            app.InputSubfolderEditFieldLabel.HorizontalAlignment = 'right';
            app.InputSubfolderEditFieldLabel.Position = [8 506 87 22];
            app.InputSubfolderEditFieldLabel.Text = 'Input Subfolder';

            % Create InputSubfolderEditField
            app.InputSubfolderEditField = uieditfield(app.UIFigure, 'text');
            app.InputSubfolderEditField.ValueChangedFcn = createCallbackFcn(app, @InputSubfolderEditFieldValueChanged, true);
            app.InputSubfolderEditField.Position = [110 506 100 22];

            % Create UnitestButton
            app.UnitestButton = uibutton(app.UIFigure, 'push');
            app.UnitestButton.ButtonPushedFcn = createCallbackFcn(app, @UnitestButtonPushed, true);
            app.UnitestButton.Position = [110 424 100 22];
            app.UnitestButton.Text = 'Unitest';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Disparity Map')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [8 31 463 347];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GUI_test

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