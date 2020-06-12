function [ varargout ] = ClimateChange( vTime, vTemp, sIndex, varargin )
%See associated README.md file for in depth explaniation of code and results


switch sIndex 
   
    case 'slope to target'
        dTarget = varargin{1}; %the foruth input is the target date
        vDiff = abs(vTime - dTarget);
        dMin = min(vDiff);
        iEndEl = find (vDiff == dMin); %finds element that is the same as dTarget or varargin
        vSlope = zeros(iEndEl-1,1); % spot to store data from the for loops with pre-alocated size
        vLB = zeros(iEndEl-1,1);
        vUB = zeros(iEndEl-1,1);
        vStartDate = vTime(1:iEndEl-1); 
        
        for iStartEl = 1:iEndEl-1; % iStartEl changes in increments of 1 from the frist elemetnt to the element before the target
            vTimeCut = vTime(iStartEl:iEndEl); %we are only using dates before the target date
            vTempCut = vTemp (iStartEl:iEndEl); %vTemp matches vTime
            mX = [vTimeCut ones(size(vTimeCut))];
            [b,bint] = regress(vTempCut, mX);%regress function slope is b, bint is confidence interval 
            vSlope(iStartEl) = b(1);
            vLB(iStartEl) = bint(1,1);
            vUB(iStartEl) = bint(1,2);
        end
        
        varargout{1} = vStartDate;
        varargout{2} = vSlope*10; % puts slope in degrees C per decade like the original
        varargout{3} = vUB*10;
        varargout{4} = vLB*10;
        
        %Plots
        plot(vStartDate, vSlope*10,'r', vStartDate, vUB*10,'b', vStartDate, vLB*10,'b')
        ylim([-.5,.5])
        title('Slope between every data point and requested date')
        ylabel('Slope')
        xlabel 'Year'
        refline(0,0)
        
    case 'slope of interval'
        dInterval = varargin {1};
        scale = (vTime(2)-vTime(1));
        iIntEl = round((1/scale)* dInterval);
        iLengthVector = length(vTime);%vTimeCut Equivalent 
        iNumData = iLengthVector - iIntEl;
        
        vSlope = zeros(iNumData,1);
        vUB = zeros(iNumData, 1);
        vLB = zeros(iNumData, 1);
        
        vStartDate = vTime(1:iNumData);
        vEndDate = vTime(iNumData:end);
        
        for iStartEl = 1:iLengthVector-iIntEl;
            iEndEl = iStartEl+iIntEl;
            
            vTimeCut = vTime(iStartEl:iEndEl);
            vTempCut = vTemp(iStartEl:iEndEl);
            
            mX = [vTimeCut ones(size(vTimeCut))];
            [b,bint] = regress(vTempCut,mX);
            vSlope(iStartEl) = b(1);
            vLB(iStartEl) = bint(1,1);
            vUB(iStartEl) = bint(1,2);
        end
        
        varargout{1} = vEndDate;  %End year of Slopes
        varargout{2} = vSlope; %Slope
        varargout{3} = vUB; %Upper bound
        varargout{4} = vLB; %lower bound
        
         %Plots
        figure
        plot(vStartDate, vSlope*10,'r', vStartDate, vUB*10,'b', vStartDate, vLB*10,'b');
        title('Slope for every period of length requested')
        ylabel('Slope')
        xlabel 'Year'
        refline(0,0)
        
        
    case 'trend since 1970'
       vDiff = abs(vTime - 1970);
       dMin = min(vDiff);
       vStartEl = find(vDiff == dMin);
       iStartEl = vStartEl(1);
       %Cut time and temp for post 1970
       vTimeCut = vTime(iStartEl:end);
       vTempCut = vTemp(iStartEl:end);
      %Create Trend Line 
       [vp, stS] = polyfit(vTimeCut,vTempCut,1); 
       vSlope = vp(1,1);
       vIntercept = vp(1,2);
       % Confidence Boundaries 
       [vY,vDelta] = polyval(vp,vTimeCut,stS);
       vUB = vY+vDelta*2;
       vLB = vY-vDelta*2;
       
       %Outputs
       varargout{1} = vSlope;
       varargout{2} = vIntercept;
       varargout{3} = vUB;
       varargout{4} = vLB;
       
       figure
       plot(vTimeCut, vY, 'r', vTimeCut, vUB, 'b', vTimeCut, vLB, 'b', vTimeCut, vTempCut, 'go') 
       title('Change in Global Mean Tempertare per Month with Trend Line and Bounds')
       ylabel('Change in Global Mean Temperature')
       xlabel('Year')
       
       
      
      
       
        
        
  
end

end

