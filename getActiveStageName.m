function [activeStageName, activeStagenum, finalStageName, nStages, prot, start_t, end_t]...
    = getActiveStageName(settings)
prot = '       ';
savedsettings = settings.saved;
if ~isempty(savedsettings.SessionDefinition_training_stages)
    activeStagenum = savedsettings.SessionDefinition_active_stage;
    stageNames = {savedsettings.SessionDefinition_training_stages{:,4}};
    if activeStagenum > length(stageNames)
        activeStageName = sprintf('%i not defined',activeStagenum);
    else
        activeStageName = stageNames{activeStagenum};
    end
    
    finalStageName  = savedsettings.SessionDefinition_training_stages{...
        end,4};
    nStages = size(savedsettings.SessionDefinition_training_stages,1);
    f = fieldnames(savedsettings);
    where_is_prot=find(cellfun(@(x) ~isempty(x), strfind(f,'prot_title')));
    
    try
    if ~isempty(where_is_prot)
        %%
        prot_ = savedsettings.(f{where_is_prot(1)});
        prot_ = strsplit(prot_);
        prot(1:length(prot_{1})) = prot_{1};
        start_t_ind =  find(~cellfun(@isempty,strfind(prot_,'Started')))+2;

        start_t = prot_{start_t_ind}(1:end-1);
        end_t_ind =  find(~cellfun(@isempty,strfind(prot_,'Ended')))+2;
        end_t = prot_{end_t_ind}(1:end-1);
    end
    catch
        start_t = nan;
        end_t   = nan;
    end
else
    activeStageName='';
    activeStagenum=[];
    finalStageName = '';
    nStages = 0;
    rigstr = '';
    start_t = '';
    end_t = '';
end

