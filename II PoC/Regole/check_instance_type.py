from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
class prova(BaseResourceCheck):
    def __init__(self):
        name = "Check instance type"
        id = "NG_TT_1"
        supported_resources = ["aws_instance"]
        categories = [CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)
    
    def scan_resource_conf(self, conf):
        try:
            tmp=conf["instance_type"][0]
        except:
            return CheckResult.FAILED
        if(tmp=="t2.micro"):
            return CheckResult.PASSED
        return CheckResult.FAILED

        '''
        return CheckResult.FAILED
        '''
check=prova()
