function [activeStageName, finalStageName, nStages, prot, start_t,end_t]...
    = getActiveStageName(settings)
prot = '       ';
if ~isempty(settings.saved.SessionDefinition_training_stages)
    activeStageName = settings.saved.SessionDefinition_training_stages{...
        settings.saved.SessionDefinition_active_stage,4};
    finalStageName  = settings.saved.SessionDefinition_training_stages{...
        end,4};
    nStages = size(settings.saved.SessionDefinition_training_stages,1);
    f = fieldnames(settings.saved);
    where_is_prot=find(cellfun(@(x) ~isempty(x), strfind(f,'prot_title')));
    try
    if ~isempty(where_is_prot)
        prot_ = settings.saved.(f{where_is_prot});
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
    finalStageName = '';
    nStages = 0;
    rigstr = '';
    start_t = '';
    end_t = '';
end

