from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
class prova(BaseResourceCheck):
    def __init__(self):
        name = "Check encryption"
        id = "NG_TT_2"
        supported_resources = ["aws_instance"]
        categories = [CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)
    
    def scan_resource_conf(self, conf):
        try:
            tmp=conf["root_block_device"][0]["encrypted"][0]
        except:
            return CheckResult.FAILED
        if(tmp==True):
            return CheckResult.PASSED
        return CheckResult.FAILED

        '''
        return CheckResult.FAILED
        '''
check=prova()