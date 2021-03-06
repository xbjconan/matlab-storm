function handles = StormMask(handles)

global CC

 
if sum(CC{handles.gui_number}.daxMask1(:)) ~= 0
    numChns = 2;
else
    numChns = 1;
end

for n=1:numChns; 
     disp(['creating mask for channel ',num2str(n)]);
     
  % load variables from previous steps
      if n==1
           daxMask= CC{handles.gui_number}.daxMask;
      else
           daxMask= CC{handles.gui_number}.daxMask1;
      end
     cluster_scale= CC{handles.gui_number}.pars0.npp/...
                       CC{handles.gui_number}.pars3.boxSize(n); 
     maxsize =      CC{handles.gui_number}.pars3.maxsize(n);
     minsize =      CC{handles.gui_number}.pars3.minsize(n);
     mindots =      CC{handles.gui_number}.pars3.mindots(n); 
     startframe =   CC{handles.gui_number}.pars3.startFrame(n); 
     mindensity =   CC{handles.gui_number}.pars3.mindensity(n);
     convI =        CC{handles.gui_number}.convI;
     folder =       CC{handles.gui_number}.source;
     binfile = CC{handles.gui_number}.binfiles(CC{handles.gui_number}.imnum).name;
     H = CC{handles.gui_number}.pars0.H;
     W = CC{handles.gui_number}.pars0.W;
     
     if n==2
         binfile = regexprep(binfile,'647','750');
     end
     CC{handles.gui_number}.currBinfiles{n} = [folder,filesep,binfile];
     
    % Step 3: Load molecule list and bin it to create image
    mlist =     ReadMasterMoleculeList([folder,filesep,binfile],'verbose',false);
    mlist =     ReZeroROI([folder,filesep,binfile],mlist);
    infilt =    mlist.frame>startframe;   
    M =         hist3([mlist.yc(infilt),mlist.xc(infilt)],...
                      {0:1/cluster_scale:H,0:1/cluster_scale:W});
    [h,w] =     size(M);             
    mask =      M>1;                                     %  figure(3); clf; imagesc(mask); 
    mask =      imdilate(mask,strel('disk',3));          %  figure(3); clf; imagesc(mask);
    toobig =    bwareaopen(mask,maxsize);                %  figure(3); clf; imagesc(mask);
    mask =      logical(mask - toobig) & imresize(daxMask,[h,w]); 
    mask =      bwareaopen(mask,minsize);                %  figure(3); clf; imagesc(mask);
    R =         regionprops(mask,M,'PixelValues','Eccentricity',...
                  'BoundingBox','Extent','Area','Centroid','PixelIdxList'); 
    aboveminsize =    cellfun(@sum,{R.PixelValues}) > mindots;
    abovemindensity = cellfun(@sum,{R.PixelValues})./[R.Area] > mindensity;
    R =         R(aboveminsize & abovemindensity);           
    
    % Just for plotting
    allpix =    cat(1,R(:).PixelIdxList);
    mask =      double(mask); 
    mask(allpix) = 3;
    if n == 1
        keep = mask>2; 
        reject = mask<2 & mask > 0;
        keep1 = 0*keep;
        reject1 = 0*reject; 
    else
        keep1 = mask>2; 
        reject1 = mask<2 & mask > 0;
    end

    % Export step data
    if n == 1
        CC{handles.gui_number}.mlist = mlist; 
        CC{handles.gui_number}.infilt = infilt; 
        CC{handles.gui_number}.R = R; % This is the STORM mask
        CC{handles.gui_number}.M = M; % This is for reference
        CC{handles.gui_number}.mlist1 = []; % helps ID number of active channels 
         CC{handles.gui_number}.M1  =[];
    elseif n == 2
        CC{handles.gui_number}.mlist1 = mlist; 
        CC{handles.gui_number}.infilt1 = infilt; 
        CC{handles.gui_number}.R1 = R; % This is the STORM mask
        CC{handles.gui_number}.M1 = M; % This is for reference
    end    
end

% plot results 
 outlines{1} = imdilate(edge(keep),strel('disk',1));
 outlines{2} = imdilate(edge(reject),strel('disk',1));
 outlines{3} = imdilate(edge(keep1),strel('disk',1));
 outlines{4} = imdilate(edge(reject1),strel('disk',1));
 CC{handles.gui_number}.outlines = outlines; 
 
 UpdateConv(handles); 
 
 


% %----------------------------
% % Troubleshooting:
% 
%    figure(1); clf;
%     plot(CC{handles.gui_number}.mlist.xc,CC{handles.gui_number}.mlist.yc,'b.');
%     hold on; 
%     plot(CC{handles.gui_number}.mlist1.xc,CC{handles.gui_number}.mlist1.yc,'ro');
%
% figure(1); clf; plot(CC{handles.gui_number}.mlist1.xc,CC{handles.gui_number}.mlist1.yc,'k.');
% figure(1); clf; imagesc(CC{handles.gui_number}.M1);
% 
% 
if n == 2
figure(2); clf; 
subplot(2,2,1); imagesc(CC{handles.gui_number}.M); caxis([0,10]);
subplot(2,2,2); imagesc(CC{handles.gui_number}.M1); caxis([0,10]);
subplot(2,2,3); imagesc(keep);
subplot(2,2,4); imagesc(keep1); colormap(hot(256));
else
    set(handles.sLayer2,'Value',0)
end