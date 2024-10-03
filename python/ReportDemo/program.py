'''Example query for reports.'''
import os, sys, json
#from ..NexarClient.nexarClient import NexarClient
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(SCRIPT_DIR, '..', 'NexarClient'))
from nexarClient import NexarClient



gqlQuery = '''
query getReports ($companyId: String!) {
  datRepReports(
    companyId: $companyId
    where: { createdDate: {gte: "2022-01-01"}}
    order: { createdDate: DESC }
  ){
    nodes {
      title
      id
      createdDate
    }
  }
}'''

if __name__ == '__main__':
    companyId = input("Please enter your company ID. \nIf you don't know your company ID, please contact your account manager. \nCompany ID: ")
    variables = {'companyId' : companyId}
    clientId = os.environ['NEXAR_CLIENT_ID']
    clientSecret = os.environ['NEXAR_CLIENT_SECRET']
    nexar = NexarClient(clientId, clientSecret, ['openid', 'user.access'])
    reports = nexar.get_query(gqlQuery, variables)['datRepReports']['nodes']
    for report in reports:
        print(f'Report Id: {report["id"]}')
        print(f'Title: {report["title"]}')
        print(f'Created Date: {report["createdDate"]}')
        print(f'\n')