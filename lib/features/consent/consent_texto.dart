/// Muda a versão sempre que alterares o texto: fica registada em cada consentimento.
const versaoConsentimento = 'fotos-v1';

/// PREENCHER: nome da clínica / médico responsável pelo tratamento dos dados.
const clinicaResponsavel = '[NOME DA CLÍNICA / MÉDICO RESPONSÁVEL]';

/// Texto do consentimento. Deve ser revisto por um jurista / encarregado de proteção de dados.
const textoConsentimento = '''
CONSENTIMENTO PARA RECOLHA E TRATAMENTO DE IMAGENS

Responsável pelo tratamento: $clinicaResponsavel.

No âmbito da minha consulta de medicina estética são recolhidas fotografias do meu rosto e/ou corpo. Estas imagens constituem dados de saúde, uma categoria especial de dados pessoais.

Declaro que fui informado(a) e autorizo, de forma livre, específica e informada, nos termos do Regulamento Geral sobre a Proteção de Dados (Regulamento (UE) 2016/679), a recolha e o tratamento das minhas imagens para as finalidades que assinalo abaixo.

Conservação e segurança: as imagens ficam guardadas no meu processo clínico, num dispositivo protegido, com acesso restrito ao profissional responsável, pelo tempo necessário à finalidade para que foram recolhidas.

Direitos: posso a qualquer momento aceder às minhas imagens, pedir a sua retificação ou apagamento, limitar o tratamento e retirar o consentimento, sem prejuízo da licitude do tratamento efetuado até então. Tenho ainda o direito de apresentar reclamação à Comissão Nacional de Proteção de Dados (www.cnpd.pt).

As finalidades opcionais são independentes: a sua recusa não afeta de modo algum o meu tratamento.
''';

const finalidadeRegisto =
    'Registo clínico: autorizo a recolha de fotografias e a sua junção ao meu processo clínico (necessário para fotografar).';
const finalidadeComparacao =
    'Comparação de resultados: autorizo o uso das imagens (antes/depois) para acompanhar e comparar a evolução do meu tratamento.';
const finalidadeDivulgacao =
    'Divulgação (opcional): autorizo o uso das imagens, de forma identificável ou não, em divulgação da clínica (site, redes sociais, apresentações).';
