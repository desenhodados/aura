import 'models.dart';

/// Modelos iniciais. Os consentimentos vêm dos teus documentos (texto original).
/// As recomendações são rascunhos: revê-as e adapta-as na própria app (ícone de documentos).
/// Depois de criados, podes editar, apagar ou acrescentar modelos na app.
final DateTime _agora = DateTime(2026, 10, 28);

final List<Modelo> modelosPadrao = [
  Modelo(
    id: 'c_toxina',
    tipo: 'consentimento',
    titulo: r'''Toxina botulínica''',
    tituloDoc: r'''CONSENTIMENTO INFORMADO PARA O TRATAMENTO COM TOXINA BOTULÍNICA''',
    texto: r'''DECLARO

1. Que a Médica Clara Jorge, com cédula profissional nº. 57166 , me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com Toxina Botulínica.

2. Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

3. A minha consulta com a Dra. e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

4. A toxina botulínica é uma toxina obtida da bactéria denominada Clostridium boulinicum. No produto a ser aplicado, a bactéria encontra-se atenuada.

5. Estas aplicações injetáveis vêm sendo usadas, há vários anos, em crianças e adultos, com a finalidade de resolver problemas de espasmo muscular, tanto na face quanto em outras regiões do corpo. Também vem sendo utilizada na área da Medicina Estética. O modo de ação verifica-se por “enfraquecimento” muscular bloqueando quimicamente a “placa motora” muscular impedindo que se verifique a contração.

6. Em Medicina Estética, esta técnica tem sido usada para amenizar rugas dinâmicas ou de expressão.

7. A aplicação injetável da toxina botulínica enfraquece o músculo tratado, impedindo a sua contração reduzindo rugas em vários sítios como testa, zona periorbitária (“pés de galinha”) entre outras localizações.

8. O modo de aplicação é por via injetável, utilizando-se uma agulha muito fina, que é introduzida diretamente no músculo a ser tratado. Não há habitualmente necessidade de anestesia, o resultado habitualmente é observado entre as 24 horas e os 5 dias após a injeção.

9. Verifica-se habitualmente uma redução das rugas, redução esta que depende da resposta individual de cada organismo.

10. ACEITO que possam ocorrer os RISCOS E COMPLICAÇÕES descritos pela ciência médica como inerentes a este tratamento. Entre outros os principais riscos que me foram explicados são os seguintes: ocasionalmente pode ocorrer um discreto edema (inchaço) e/ou equimose (mancha roxa) na área tratada. Raramente, o músculo adjacente pode ficar enfraquecido (por uma, ou por várias semanas após a injeção). Qualquer dúvida deve contactar o médico que realizou o procedimento.

11. Por se tratar de ação química, este tratamento não é definitivo, pois o produto perde o seu efeito após 4 a 8 meses com uma variação que depende do organismo do doente. Cada nova aplicação deverá ser paga de forma individual.

12. CONFIRMO que o tratamento mencionado, foi-me explicado com detalhe, em palavras compreensíveis, dos riscos que existem, os efeitos indesejados, os riscos inerentes à minha pessoa, assim como o desconforto ou, em ocasiões, dores que possa sentir tendo um pós-tratamento normal. Explicaram-me igualmente outras opções existentes que estão disponíveis no mercado, com os prós e contras de cada uma delas. Tendo tudo isso em conta, escolhi a intervenção anteriormente descrita.

13. AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso.

14. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

15. COMPREENDO que o objetivo do tratamento é melhorar minha aparência existindo a possibilidade de que alguma imperfeição persista e que o resultado possa não ser o esperado por mim. Neste sentido, tenho conhecimento que o resultado estético do tratamento depende de fatores como a facilidade de cicatrização, formação ou não de quelóides, aparecimento de reações ao produto (como por exemplo, fibrose). Sei que a medicina não é uma ciência exata e que ninguém pode garantir a perfeição absoluta. Compreendo que o resultado pode não ser o esperado por mim e reconheço que não me deram, em absoluto, tal garantia.

16. INFORMARAM-ME que o número de sessões e/ou quantidade de produto que serão necessários para conseguir o efeito desejado, comunicados pelos profissionais, se trata de uma estimativa, dada como forma de orientação. Sendo impossível, previamente, conhecer a quantidade exata de produto ou número de sessões que serão necessárias, pelas diferentes formas de absorção/reação de cada paciente.

17. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

18. CONFIRMO de não haver omitido ou alterado os meus dados e antecedentes clínico- cirúrgicos, especialmente os relacionados a alergias e doenças ou riscos pessoais.

19. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

20. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

21. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Pude esclarecer todas minhas duvidas relacionadas com o anteriormente exposto e entendi totalmente este DOCUMENTO DE CONSENTIMENTO reafirmando-me em todos e cada um dos seus pontos e com a assinatura do documento EM TODAS AS PÁGINAS E EM DUPLICADO ratifico e consinto que o tratamento se realize.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'c_hialuronico',
    tipo: 'consentimento',
    titulo: r'''Ácido hialurónico''',
    tituloDoc: r'''DOCUMENTO DE CONSENTIMIENTO INFORMADO PARA IMPLANTES DE ÁCIDO HIALURÓNICO''',
    texto: r'''DECLARO

1. Que a Médica Clara Jorge, com cédula profissional nº. 57166 , me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com ácido hialurónico.

2. Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

3. A minha consulta com a Dra. e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

4. O ácido hialurónico é utilizado para a correção temporal de defeitos cutâneos, linhas e rugas faciais, assim como para o realce dos lábios e remodelação do contorno facial. Pode também ser utilizado para melhorar cicatrizes.

5. É uma substancia compatível com o organismo humano, que tem sido testado em numerosos pacientes, elaborada de acordo com a norma sanitária vigente e devidamente aprovado para seu uso em Espanha e restantes países da União Europeia, não tendo surgido até ao momento complicações graves.

6. Para a sua administração não é necessário internamento hospitalar. Trata-se de um tratamento ambulatório. Em alguns casos é necessário realizar uma anestesia troncular ou aplicar um creme anestésico, adequado à tolerância do paciente.

7. A Dra. explicou-me a utilização e as indicações dos produtos, tendo respondido a todas as perguntas que lhe coloquei de forma satisfatória. Informou-me que, após o tratamento, poderão ocorrer alguns problemas associados ao tratamento, como vermelhidão, inchaço ou hematomas na zona do implante.

8. Em situações muito pouco frequentes, poderão observar-se reações de tipo alérgico, com estados inflamatórios mais intensos que os anteriores. Estas reações surgem geralmente alguns dias após o tratamento, sendo de grau moderado que pode persistir durante algumas semanas. Excecionalmente, têm uma duração superior. Regra geral, a maioria das complicações resolvem-se com o tempo.

9. Tratando-se de um tratamento do setor médico-estético, pode também provocar resultados insatisfatórios, apesar de ocorrerem raramente. Não existem garantias de resultados devido a fenómenos de natureza múltipla. A durabilidade do produto pode variar de pessoa para pessoa, na ordem dos 4-12 meses.

10. AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso.

11. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

12. COMPREENDO que o objetivo do tratamento é melhorar minha aparência existindo a possibilidade de que alguma imperfeição persista e que o resultado possa não ser o esperado por mim. Neste sentido, tenho conhecimento que o resultado estético do tratamento depende de fatores como a facilidade de cicatrização, formação ou não de quelóides, aparecimento de reações ao produto (como por exemplo, fibrose). Sei que a medicina não é uma ciência exata e que ninguém pode garantir a perfeição absoluta. Compreendo que o resultado pode não ser o esperado por mim e reconheço que não me deram, em absoluto, tal garantia.

13. INFORMARAM-ME que o número de sessões e/ou quantidade de produto que serão necessários para conseguir o efeito desejado, comunicados pelos profissionais, se trata de uma estimativa, dada como forma de orientação. Sendo impossível, previamente, conhecer a quantidade exata de produto ou número de sessões que serão necessárias, pelas diferentes formas de absorção/reação de cada paciente.

14. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

15. CONFIRMO de não haver omitido ou alterado os meus dados e antecedentes clínico- cirúrgicos, especialmente os relacionados a alergias e doenças ou riscos pessoais.

16. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

17. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

18. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Pude esclarecer todas minhas duvidas relacionadas com o anteriormente exposto e entendi totalmente este DOCUMENTO DE CONSENTIMENTO reafirmando-me em todos e cada um dos seus pontos e com a assinatura do documento EM TODAS AS PÁGINAS E EM DUPLICADO ratifico e consinto que o tratamento se realize.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'c_profhilo',
    tipo: 'consentimento',
    titulo: r'''Profhilo''',
    tituloDoc: r'''DOCUMENTO DE CONSENTIMIENTO INFORMADO PARA PROFHILO®''',
    texto: r'''DECLARO

1. Que a Médica Clara Jorge, com cédula profissional nº. 57166 , me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com PROFHILO®.

2. Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

3. A minha consulta com a Dra. e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

4. O PROFHILO®é utilizado para a correção temporal de defeitos cutâneos, linhas e rugas faciais. Pode também ser utilizado para melhorar cicatrizes.

5. É uma substancia compatível com o organismo humano, que tem sido testado em numerosos pacientes, elaborada de acordo com a norma sanitária vigente e devidamente aprovado para seu uso em Portugal e restantes países da União Europeia, não tendo surgido até ao momento complicações graves.

6. Para a sua administração não é necessário internamento hospitalar. Trata-se de um tratamento ambulatório. Em alguns casos é necessário realizar uma anestesia troncular ou aplicar um creme anestésico, adequado à tolerância do paciente.

7. A Dra. explicou-me a utilização e as indicações do produto, tendo respondido a todas as perguntas que lhe coloquei de forma satisfatória. Compreendo que após o tratamento com o produto acima mencionado: Pode haver incidentes de reações inflamatórias (vermelhidão, edema, etc.) por vezes associados à comichão e à dor ao toque. Estas reações podem persistir durante 7/10 dias. Podem ocorrer endurecimentos ou nódulos no local da injeção. Também fui informado de casos muito raros, descritos na literatura, de descoloração no local da injeção, necrose da área glabelar, abcesso, granuloma e hipersensibilidade, após injeções de ácido hialurónico.

8. Se as reações inflamatórias persistirem por mais de 7/10 dias, devo contactar o meu médico imediatamente.

9. Em situações muito pouco frequentes, poderão observar-se reações de tipo alérgico, com estados inflamatórios mais intensos que os anteriores. Estas reações surgem geralmente alguns dias após o tratamento, sendo de grau moderado que pode persistir durante algumas semanas. Excecionalmente, têm uma duração superior. Regra geral, a maioria das complicações resolvem-se com o tempo.

10. Tratando-se de um tratamento do setor médico-estético, pode também provocar resultados insatisfatórios, apesar de ocorrerem raramente. Não existem garantias de resultados devido a fenómenos de natureza múltipla. A durabilidade do produto pode variar consoante o tipo de pele, a área tratada, a quantidade injetada e as técnicas de injeção.

11. AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso.

12. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

13. COMPREENDO que o objetivo do tratamento é melhorar minha aparência existindo a possibilidade de que alguma imperfeição persista e que o resultado possa não ser o esperado por mim. Neste sentido, tenho conhecimento que o resultado estético do tratamento depende de fatores como a facilidade de cicatrização, formação ou não de quelóides, aparecimento de reações ao produto (como por exemplo, fibrose). Sei que a medicina não é uma ciência exata e que ninguém pode garantir a perfeição absoluta. Compreendo que o resultado pode não ser o esperado por mim e reconheço que não me deram, em absoluto, tal garantia.

14. INFORMARAM-ME que o número de sessões e/ou quantidade de produto que serão necessários para conseguir o efeito desejado, comunicados pelos profissionais, se trata de uma estimativa, dada como forma de orientação. Sendo impossível, previamente, conhecer a quantidade exata de produto ou número de sessões que serão necessárias, pelas diferentes formas de absorção/reação de cada paciente.

15. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

16. CONFIRMO de não haver omitido ou alterado os meus dados e antecedentes clínico- cirúrgicos, especialmente os relacionados a alergias e doenças ou riscos pessoais.

17. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

18. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

19. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Pude esclarecer todas minhas duvidas relacionadas com o anteriormente exposto e entendi totalmente este DOCUMENTO DE CONSENTIMENTO reafirmando-me em todos e cada um dos seus pontos e com a assinatura do documento EM TODAS AS PÁGINAS E EM DUPLICADO ratifico e consinto que o tratamento se realize.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'c_nctf',
    tipo: 'consentimento',
    titulo: r'''NCTF HA (polirevitalização facial)''',
    tituloDoc: r'''DOCUMENTO DE CONSENTIMIENTO INFORMADO O TRATAMENTO DE POLIREVITALIZAÇÃO FACIAL COM NCTF HA MESOLIFT''',
    texto: r'''DECLARO

1. Que a Médica Clara Jorge, com cédula profissional nº. 57166 , me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com conhecido como Polirevitalização Facial com NCTF HA.

2. Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

3. A minha consulta com a Dra. e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

4. O objetivo da técnica é melhorar o envelhecimento facial, obter efeito reafirmante e melhorar as rugas do rosto e pescoço.

5. O tratamento consiste na administração subcutânea ou intradérmica de pequenas quantidades de medicamentos alopáticos ou homeopáticos; estes últimos facultam maiores garantias ao permitir um tratamento personalizado, carecer de efeitos colaterais e não produzir reações alérgicas, procurando que estes atuem, revitalizando a pele. As microinjeções, realizam-se com agulhas muito finas e pouco dolorosas.

6. Neste procedimento realizaremos uma mesoterapia facial com vitaminas, ácido Hialurónico, aminoácidos, oligoelementos, coenzimas, antiradicais livres e outros produtos que vão produzir um rejuvenescimento facial.

7. Compreendo que apesar da adequada escolha da técnica e da sua correta realização, podem apresentar-se efeitos indesejáveis, como inchaço, enrijecimento, dor, comichão, pápula, raramente poderão aparecer infeções e muito raramente necroses na zona infiltrada. Também podem aparecer hematomas que desaparecem espontaneamente em alguns dias e pigmentação na zona tratada.

8. A Dra. Clara Jorge advertiu-me, proibindo-me expressamente, a exposição solar ou a raios UV, antes e depois de cada sessão e que devo usar diariamente proteção solar durante, no mínimo um mês depois do procedimento. Proibiu-me terminantemente de utilizar saunas, ou piscinas até passado 1 ou 2 dias depois da intervenção.

9. A Dra. Clara Jorge advertiu-me que existe uma possibilidade, ainda que mínima, do aparecimento de pigmentação na zona de tratamento, principalmente se houver exposição solar ou a lâmpadas UV depois do mesmo. A possibilidade de hematomas é um risco frequente que depende também da toma de determinados medicamentos por parte do paciente (por exemplo, aspirina e outros anticoagulantes).

10. Tratando-se de um tratamento do setor médico-estético, pode também provocar resultados insatisfatórios, apesar de ocorrerem raramente. Não existem garantias de resultados devido a fenómenos de natureza múltipla.

11. AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso.

12. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

13. COMPREENDO que o objetivo do tratamento é melhorar minha aparência existindo a possibilidade de que alguma imperfeição persista e que o resultado possa não ser o esperado por mim. Neste sentido, tenho conhecimento que o resultado estético do tratamento depende de fatores como a facilidade de cicatrização, formação ou não de quelóides, aparecimento de reações ao produto (como por exemplo, fibrose). Sei que a medicina não é uma ciência exata e que ninguém pode garantir a perfeição absoluta. Compreendo que o resultado pode não ser o esperado por mim e reconheço que não me deram, em absoluto, tal garantia.

14. INFORMARAM-ME que o número de sessões e/ou quantidade de produto que serão necessários para conseguir o efeito desejado, comunicados pelos profissionais, se trata de uma estimativa, dada como forma de orientação. Sendo impossível, previamente, conhecer a quantidade exata de produto ou número de sessões que serão necessárias, pelas diferentes formas de absorção/reação de cada paciente.

15. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

16. INFORMEI o médico de todos os dados do meu historial clínico, como alergias, doenças ou tratamentos que me foram realizados e expressamente de tratamentos com outros materiais na zona a tratar. A Dra. Clara Jorge também me advertiu da importância de ter conhecimento dos meus antecedentes pessoais de possíveis alergias a medicamentos, fotossensibilidade, alterações de coagulação, doenças cardiopulmonares, existência de próteses, pacemaker ou medicação atual, antecedentes de herpes simples facial, antecedentes pessoais ou familiares de coloides ou qualquer outra circunstância.

17. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

18. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

19. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Pude esclarecer todas minhas duvidas relacionadas com o anteriormente exposto e entendi totalmente este DOCUMENTO DE CONSENTIMENTO reafirmando-me em todos e cada um dos seus pontos e com a assinatura do documento EM TODAS AS PÁGINAS E EM DUPLICADO ratifico e consinto que o tratamento se realize.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'c_mesoterapia',
    tipo: 'consentimento',
    titulo: r'''Mesoterapia''',
    tituloDoc: r'''CONSENTIMENTO INFORMADO PARA O TRATAMENTO DE MESOTERAPIA''',
    texto: r'''DECLARO

1. Que a Médica Clara Jorge, com cédula profissional nº. 57166 , me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com Mesoterapia.

2. Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

3. A minha consulta com a Dra. e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

4. A mesoterapia consiste na infiltração de substâncias farmacológicas no espaço subdérmico em pequenas quantidades. O tipo de substância se escolhe em função do problema a tratar. Com este tratamento consegue-se melhorar a celulite, problemas circulatórios, promove também um efeito reafirmante e suaviza o aspecto das rugas do rosto e do pescoço.

5. As substâncias e equipamentos utilizados foram autorizados para o seu uso em medicina estética e ostenta a marca CE e registo na autoridade competente.

6. CONFIRMO que o tratamento mencionado, foi-me explicado com detalhe, pela médica em palavras compreensíveis, dos riscos que existem, os efeitos indesejados, os riscos inerentes a minha pessoa, assim como o desconforto ou, em ocasiões, dores que possa sentir tendo um pós-tratamento normal. Explicaram-me igualmente outras opções existentes que estão disponíveis no mercado, com os prós e contras de cada uma delas. Tendo tudo isso em conta, escolhi a intervenção anteriormente descrita.

7. ACEITO que possam ocorrer os RISCOS E COMPLICAÇÕES descritos pela ciência médica como inerentes a este tratamento. Entre outros os principais riscos que me foram explicados são os seguintes:

- Riscos e complicações comuns a qualquer tratamento estético, como reações alérgicas à substância utilizada ou à anestesia tópica (geralmente leves, que requerem um tratamento adequado simples ou incluso nenhum tratamento), hematomas, edemas ou inflamação, que geralmente desaparecem em pouco tempo sem necessidade de ser tratados.

- Riscos e complicações específicos deste procedimento, que me foram explicados, e os quais assumo e aceito. Podem ocorrer pequenos hematomas ou crostas depois da injeção, que desaparecerão em uns dias sem apresentar maiores complicações.

- Contraindicações: pacientes que apresentem coagulopatías ou estejam em tratamento com anticoagulantes.

8. AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso.

9. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

10. COMPREENDO que o objetivo do tratamento é melhorar minha aparência existindo a possibilidade de que alguma imperfeição persista e que o resultado possa não ser o esperado por mim. Neste sentido, tenho conhecimento que o resultado estético do tratamento depende de fatores como a facilidade de cicatrização, formação ou não de quelóides, aparecimento de reações ao produto (como por exemplo, fibrose). Sei que a medicina não é uma ciência exata e que ninguém pode garantir a perfeição absoluta. Compreendo que o resultado pode não ser o esperado por mim e reconheço que não me deram, em absoluto, tal garantia.

11. INFORMARAM-ME que o número de sessões e/ou quantidade de produto que serão necessários para conseguir o efeito desejado, comunicados pelos profissionais, se trata de uma estimativa, dada como forma de orientação. Sendo impossível, previamente, conhecer a quantidade exata de produto ou número de sessões que serão necessárias, pelas diferentes formas de absorção/reação de cada paciente. Habitualmente se realizam varias sessões com intervalos de tempo regulares, cujo número e frequência dependerão do objetivo a atingir e tipo de peeling.

12. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

13. CONFIRMO de não haver omitido ou alterado os meus dados e antecedentes clínico- cirúrgicos, especialmente os relacionados a alergias e doenças ou riscos pessoais.

14. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

15. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

16. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Pude esclarecer todas minhas duvidas relacionadas com o anteriormente exposto e entendi totalmente este DOCUMENTO DE CONSENTIMENTO reafirmando-me em todos e cada um de seus pontos e com a assinatura do documento EM TODAS AS PÁGINAS E EM DUPLICADO ratifico e consinto que o tratamento se realize.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'c_microneedling',
    tipo: 'consentimento',
    titulo: r'''Microneedling''',
    tituloDoc: r'''CONSENTIMENTO INFORMADO PARA O TRATAMENTO DE MICRONEEDLING''',
    texto: r'''DECLARO

1. Que a Médica Clara Jorge, com cédula profissional nº. 57166 , me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com Microneedling.

2. Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

3. A minha consulta com a Dra. e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

4. A mesoterapia utilizada como procedimento estético consiste na injeção intradérmica de vitaminas, oligoelementos, agentes antioxidantes, minerais e/ou ácido hialurónico.

5. O microneedling consiste no microagulhamento da superfície cutânea, abrindo-se, assim, microcanais que possibilitam a absorção transdérmica dos princípios ativos supramencionados.

6. A seleção do método mais adequado ou a conjugação dos dois métodos é de acordo com o caso em questão e será é aconselhado pela médica.

7. O objetivo destas técnicas é retardar os efeitos do envelhecimento facial e/ou corporal, produzindo um rejuvenescimento ao estimular a produção de colagénio e elastina promovendo uma pele mais elástica, hidratada, luminosa e jovem, tendo também benefícios em cicatrizes.

8. Esta técnica realiza-se, de uma forma geral em 3 sessões com 20 a 30 dias de espaçamento entre elas e, posteriormente, repetidas de 3/3 meses. No entanto, tal varia de acordo com cada caso e os objetivos a alcançar, bem como, com a realização de tratamentos complementares. No caso p.e. de rugas profundas deverá complementar-se com a infiltração de ácido hialurónico reticulado.

9. Foi-me explicado pela médica que o tratamento é praticamente indolor, mas que poderá provocar um ligeiro incómodo geralmente bem suportado.

10. A médica informou-me das COMPLICAÇÕES OU CONSEQUÊNCIAS INDESEJÁVEIS que podem advir como consequência deste tratamento, tais como:

- Hematomas, edema, eritema, picadas que geralmente duram vários dias e que podem aparecer associados a prurido nos locais de injeção;

- Infeção;

- Dor nas zonas de aplicação ao exercer pressão;

- Formação de nódulos ou elevação da zona tratada nos pontos de injeção;

- Prurido;

- Lesões tipo acne;

- Reação alérgica;

- Despigmentação ou hiperpigmentação no ponto de injeção.

11. No entanto, a médica indicou-me que todas estas complicações são de pouca importância e habitualmente transitórias. EXCECIONALMENTE E EM RARAS OCASIÕES podem aparecer reações tardias como granulomas, abcessos e necroses, no entanto, fui ADVERTIDA, pela médica, acerca da possibilidade de reativação de um Herpes Simplex existente.

12. A médica advertiu-me sobre as CONTRAINDICAÇÕES que existem para a realização deste tratamento:

- Lesões agudas ou crónicas da pele na proximidade do local de tratamento;

- Gravidez ou aleitamento;

- Doença provocada por Streptococcus;

- Antecedentes de Doenças auto-imunes ou tratamentos de imunoterapia; /3

- Hipersensibilidade ao produto injetado;

- Não deve ser aplicado em zonas que apresentem processos infeciosos e/ou inflamatórios cutâneos (ex: acne...);

- Após o tratamento não se devem realizar outros tratamentos na mesma área.

13. Declaro que NÃO SOFRO DE NENHUMA das contraindicações descritas, que não solicitei o tratamento numa zona que apresente um processo infecioso ou inflamatório e que NÃO ME SUBMETEREI, até que o médico me autorize expressamente, a qualquer outro tratamento na mesma zona tratada ou adjacente.

14. Para alem disto, o médico informou-me que devo seguir as indicações prescritas por ele durante e depois a realização do tratamento e adverte-me que: não me devo maquilhar durante 12 horas após; devo evitar a exposição solar prolongada aos raios UV, a temperaturas excessivamente frias, assim como a saunas ou banhos turcos, durante as duas semanas seguintes.

15. AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso.

16. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

17. COMPREENDO que o objetivo do tratamento é melhorar minha aparência existindo a possibilidade de que alguma imperfeição persista e que o resultado possa não ser o esperado por mim. Neste sentido, tenho conhecimento que o resultado estético do tratamento depende de fatores como a facilidade de cicatrização, formação ou não de quelóides, aparecimento de reações ao produto (como por exemplo, fibrose). Sei que a medicina não é uma ciência exata e que ninguém pode garantir a perfeição absoluta. Compreendo que o resultado pode não ser o esperado por mim e reconheço que não me deram, em absoluto, tal garantia.

18. INFORMARAM-ME que o número de sessões e/ou quantidade de produto que serão necessários para conseguir o efeito desejado, comunicados pelos profissionais, se trata de uma estimativa, dada como forma de orientação. Sendo impossível, previamente, conhecer a quantidade exata de produto ou número de sessões que serão necessárias, pelas diferentes formas de absorção/reação de cada paciente. Habitualmente se realizam varias sessões com intervalos de tempo regulares, cujo número e frequência dependerão do objetivo a atingir e tipo de peeling.

19. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

20. CONFIRMO de não haver omitido ou alterado os meus dados e antecedentes clínico- cirúrgicos, especialmente os relacionados a alergias e doenças ou riscos pessoais.

21. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

22. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

23. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Pude esclarecer todas minhas duvidas relacionadas com o anteriormente exposto e entendi totalmente este DOCUMENTO DE CONSENTIMENTO reafirmando-me em todos e cada um de seus pontos e com a assinatura do documento EM TODAS AS PÁGINAS E EM DUPLICADO ratifico e consinto que o tratamento se realize.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'c_peeling',
    tipo: 'consentimento',
    titulo: r'''Peeling químico''',
    tituloDoc: r'''CONSENTIMENTO INFORMADO PARA O TRATAMENTO DE PEELING QUÍMICO''',
    texto: r'''DECLARO

1. Que a Médica Clara Jorge, com cédula profissional nº. 57166 , me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com Peeling Químico.

2. Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

3. A minha consulta com a Dra. e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

4. O peeling químico e outros tratamentos cutâneos realizam-se há muitos anos para tratar diversas alterações da pele. Situações como danos por exposição solar, rugas e pigmentação irregular podem ser tratadas com estas técnicas não invasivas. Existem diferentes técnicas para a aplicação de peeling químico e medicações de uso e tratamento cutâneo.

5. As formas de tratamento alternativo, não incluem tratar a pele com agentes de Peeling químico ou outras medicações. A melhoria nas lesões cutâneas e rugas podem conseguir-se através de outros tratamentos como dermobrasão, tratamento com laser fraccionado, ou cirurgia (lifting) para esticar a pele flácida. Existem riscos e complicações potenciais associadas às formas alternativas de tratamento.

6. O tratamento de peeling químico consiste na aplicação de um produto químico (normalmente um ácido) sobre a pele previamente preparada. A duração do tratamento varia segundo o tipo de peeling, mas oscila entre 10 e 30 minutos.

7. As substâncias e equipamentos utilizados foram autorizados para o seu uso em medicina estética e ostentam a marca CE e registo na autoridade competente.

8. CONFIRMO que o tratamento mencionado, foi-me explicado com detalhe, em palavras compreensíveis, dos riscos que existem, os efeitos indesejados, os riscos inerentes à minha pessoa, assim como o desconforto ou, em ocasiões, dores que possa sentir tendo um pós-tratamento normal. Explicaram-me igualmente outras opções existentes que estão disponíveis no mercado, com os prós e contras de cada uma delas. Tendo tudo isso em conta, escolhi a intervenção anteriormente descrita.

9. ACEITO que possam ocorrer os RISCOS E COMPLICAÇÕES descritos pela ciência médica como inerentes a este tratamento. Entre outros os principais riscos que me foram explicados são os seguintes: Riscos:

- Riscos e complicações comuns a qualquer tratamento estético, como reações alérgicas à substância utilizada (geralmente leves, que requerem um tratamento adequado simples ou incluso nenhum tratamento), hematomas, edemas ou inflamação, que geralmente desaparecem em pouco tempo sem necessidade de ser tratados. -Riscos e complicações específicos deste tratamento, que me foram explicados, e os quais assumo e aceito. Complicações:

- Infeção. A infeção não é frequente, mas podem ocorrer infeções bacterianas ou víricas. Se o paciente tem antecedentes de infeções por Herpes simplex (herpes labial), é possível que uma infeção possa ocorrer depois de um peeling químico. Poderá ser prescrita profilaxia antivírica antes do peeling com o objetivo de evitar uma infeção por este vírus. Quando ocorre qualquer tipo de infeção da pele pode ser necessário um tratamento adicional, incluindo antibióticos.

- Cicatrização. Ainda que se espere uma boa recuperação depois deste procedimento, podem aparecer cicatrizes anormais tanto na pele como nos tecidos profundos. Em casos raros podem resultar em cicatrizes quelóides. As cicatrizes podem ser antiestéticas ou apresentar coloração diferente à da pele circundante. Podem ser necessários tratamentos adicionais para tratar a cicatrização anormal.

- Alteração de coloração. Os agentes de peeling químico podem modificar de forma permanente o tom natural da pele. Existe a possibilidade que ocorram alterações irregulares da coloração na pele, com áreas que podem ser mais claras ou mais escuras. Foram descritos casos de hiperpigmentação permanente da pele depois de peelings químicos. Pode aparecer uma linha de demarcação entre a pele normal e a pele tratada com peeling. Após um peeling poderá persistir hiperémia durante um tempo anormalmente mais prolongado.

- Fracos Resultados. Existe a possibilidade de que se obtenham fracos resultados com estes procedimentos.

- Recorrências de lesões cutâneas. As lesões da pele podem voltar a aparecer em algumas situações depois de um peeling ou tratamento cutâneo. Pode ser necessário tratamento adicional ou posterior cirurgia.

- Cancro ou doenças da pele. Os peelings e tratamentos da pele não oferecem proteção contra o desenvolvimento de cancro de pele ou outras doenças num futuro.

- Reações alérgicas. Em casos raros foram descritas reações alérgicas a medicamentos e agentes usados no peeling químico ou tratamentos cutâneos. Em casos raros ocorreram reações alérgicas no local do adesivo, conservantes usados em cosméticos ou preparados tópicos. As reações sistémicas, que são más sérias, podem ocorrer por medicamentos utilizados durante o procedimento ou prescritos depois. As reações alérgicas podem requerer tratamento adicional.

- Queimaduras solares. Certos tipos de agentes de peeling químico podem favorecer de forma permanente as queimaduras cutâneas por sol. A pele depois de um peeling químico pode perder a capacidade normal para bronzear-se quando se expõe à luz solar.

- Ausência de resultados permanentes. O peeling químico ou outros tratamentos da pele podem não melhorar ou prevenir completamente as futuras rugas da pele. Nenhuma técnica pode reverter os sinais de envelhecimento da pele. Pode ser necessário um programa de manutenção da pele depois de um procedimento de peeling químico.

- A recuperação pode tardar um tempo mais longo que o previsto depois de um peeling ou outro tratamento da pele. A cura da pele pode resultar em uma pele mais fina e delicada, o que é diferente da normal vermelhidão da pele depois de um peeling.

- Problemas cardíacos. Alguns agentes de peeling químico podem produzir ritmos cardíacos anormais que podem requerer tratamento médico se ocorrem durante o procedimento. Este é um problema potencialmente sério.

- Riscos desconhecidos. Existe a possibilidade de que sejam descobertos fatores de risco adicionais no peeling químico e tratamentos da pele.

10. AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso.

11. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

12. COMPREENDO que o objetivo do tratamento é melhorar minha aparência existindo a possibilidade de que alguma imperfeição persista e que o resultado possa não ser o esperado por mim. Neste sentido, tenho conhecimento que o resultado estético do tratamento depende de fatores como a facilidade de cicatrização, formação ou não de quelóides, aparecimento de reações ao produto (como por exemplo, fibrose). Sei que a medicina não é uma ciência exata e que ninguém pode garantir a perfeição absoluta. Compreendo que o resultado pode não ser o esperado por mim e reconheço que não me deram, em absoluto, tal garantia.

13. INFORMARAM-ME que o número de sessões e/ou quantidade de produto que serão necessários para conseguir o efeito desejado, comunicados pelos profissionais, se trata de uma estimativa, dada como forma de orientação. Sendo impossível, previamente, conhecer a quantidade exata de produto ou número de sessões que serão necessárias, pelas diferentes formas de absorção/reação de cada paciente. Habitualmente se realizam varias sessões com intervalos de tempo regulares, cujo número e frequência dependerão do objetivo a atingir e tipo de peeling.

14. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

15. CONFIRMO de não haver omitido ou alterado os meus dados e antecedentes clínico- cirúrgicos, especialmente os relacionados a alergias e doenças ou riscos pessoais.

16. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

17. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

18. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Pude esclarecer todas minhas duvidas relacionadas com o anteriormente exposto e entendi totalmente este DOCUMENTO DE CONSENTIMENTO reafirmando-me em todos e cada um dos seus pontos e com a assinatura do documento EM TODAS AS PÁGINAS E EM DUPLICADO ratifico e consinto que o tratamento se realize.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'c_fios',
    tipo: 'consentimento',
    titulo: r'''Fios tensores''',
    tituloDoc: r'''DOCUMENTO DE CONSENTIMIENTO INFORMADO PARA COLOCAÇÃO DE FIOS TENSORES''',
    texto: r'''DECLARO

1. Que a Médica Clara Jorge, com cédula profissional nº. 57166, me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com fios tensores.

2. Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

3. A minha consulta com a Dra. e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

4. O implante dos fios tensores é feito ambulatoriamente com anestesia local, sem necessidade de internamento.

5. Os fios faciais ficam alojados na camada de gordura, não causam ondulações na face e não são visíveis ou palpáveis.

6. Cada fio é colocado através de microcânula e os pontos de entrada e saída da cânula guia na pele fecham-se imediatamente. fio é inserido logo abaixo da pele através de uma agulha. Em seguida, a profissional faz uma tração manual do fio, suspendendo a pele de acordo com a necessidade de cada paciente. O fio possui pequenos cones ou garras que se fixam no subcutâneo, impedindo o seu deslocamento após o tratamento.

7. Os fios são feitos de polímeros 100% absorvíveis (ácido polilático ou polidioxanona). Ao serem reabsorvidos pelo organismo, esses polímeros estimulam a formação de colágeno novo na pele. Dessa forma, o tratamento atua de duas maneiras: a) efeito de lifting suave logo após a aplicação dos fios; b) efeito regenerador ao estimular a ativação dos fibroblastos e a produção de colágeno nos meses seguintes, proporcionando resultados progressivos e naturais.

ORIENTAÇÕES PÓS-PROCEDIMENTO

8. No primeiro dia pós-procedimento é recomendável manter a cabeça erguida;

9. Não ingerir bebidas alcoólicas ou utilizar a sauna no dia do tratamento e pós-tratamento;

10. Aplicar gelo 3 vezes ao dia no local nas primeiras 48 horas;

11. Caso sinta dor, utilizar analgésico sem ação anti-inflamatória;

12. Não se expor a calor excessivo durante 4 semanas;

13. Dormir com a cabeceira da cama elevada por 3 dias;

14. Não dormir de bruços;

15. Retorno das atividades habituais em 72 horas (ginásio);

16. Não ingerir anti-inflamatórios durante as duas primeiras semanas.

17. Tratando-se de um tratamento do setor médico-estético, pode também provocar resultados insatisfatórios, apesar de ocorrerem raramente. Não existem garantias de resultados devido a fenómenos de natureza múltipla. A durabilidade do produto pode variar de pessoa para pessoa, na ordem dos 4-12 meses.

18. ACEITO que os RISCOS E COMPLICAÇÕES descritos pela ciência médica como inerentes a este tratamento podem ocorrer. Entendo que apesar da escolha apropriada do tratamento e seu desempenho correto, efeitos indesejáveis frequentes e previsíveis como edema, vermelhidão, dor, prurido, também podem aparecer hematomas que desaparecem espontaneamente em vários dias.

19. Presumo que, como resultado do tratamento, poderia sofrer danos cosméticos em vez de melhoras. Entre outros riscos principais, são os seguintes:

20. Riscos e complicações comuns a qualquer tratamento estético, entre outros, reações alérgicas à substância utilizada (geralmente leves, que remitem com o tratamento adequado ou mesmo sem tratamento), hematomas, edema ou inflamação que geralmente remitem em pouco tempo sem necessidade ser tratado.

21. Riscos e complicações atribuíveis ao procedimento anestésico.

22. Riscos específicos relacionados ao procedimento como assimetrias, irregularidades cutâneas, reações alérgicas locais ou sistêmicas, reações inflamatórias (rubor, edema, eritema) que podem estar associadas a prurido e dor ao exercer pressão; também podem aparecer hematomas que desaparecem espontaneamente em vários dias; O herpes recorrente pode ser reativado, da mesma forma podem surgir endurecimento, nódulos e / ou extrusão do mesmo.

23. Excecionalmente, foram descritas infeções (se ocorrerem, pode ser necessário tratamento adicional, incluindo antibióticos), reações como granulomas, abscessos e necrose, bem como cicatrizes pós-tratamento (deprimidas, retráteis e / ou quelóides) e hipo ou hiperpigmentação. Outras reações raras são a perda de função e reações alérgicas que podem desencadear choque anafilático e edema angioneurótico. O aumento da sensibilidade e da dor ao pressionar ou apoiar a área tratada pode durar anos.

24. AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso.

25. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

26. COMPREENDO que o objetivo do tratamento é melhorar minha aparência existindo a possibilidade de que alguma imperfeição persista e que o resultado possa não ser o esperado por mim. Neste sentido, tenho conhecimento que o resultado estético do tratamento depende de fatores como a facilidade de cicatrização, formação ou não de quelóides, aparecimento de reações ao produto (como por exemplo, fibrose). Sei que a medicina não é uma ciência exata e que ninguém pode garantir a perfeição absoluta. Compreendo que o resultado pode não ser o esperado por mim e reconheço que não me deram, em absoluto, tal garantia.

27. INFORMARAM-ME que o número de sessões e/ou quantidade de produto que serão necessários para conseguir o efeito desejado, comunicados pelos profissionais, se trata de uma estimativa, dada como forma de orientação. Sendo impossível, previamente, conhecer a quantidade exata de produto ou número de sessões que serão necessárias, pelas diferentes formas de absorção/reação de cada paciente.

28. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

29. CONFIRMO de não haver omitido ou alterado os meus dados e antecedentes clínico- cirúrgicos, especialmente os relacionados a alergias e doenças ou riscos pessoais.

30. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

31. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

32. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Pude esclarecer todas minhas duvidas relacionadas com o anteriormente exposto e entendi totalmente este DOCUMENTO DE CONSENTIMENTO reafirmando-me em todos e cada um dos seus pontos e com a assinatura do documento EM TODAS AS PÁGINAS E EM DUPLICADO ratifico e consinto que o tratamento se realize.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'c_aqualyx',
    tipo: 'consentimento',
    titulo: r'''Aqualyx (intralipoterapia)''',
    tituloDoc: r'''CONSENTIMENTO INFORMADO PARA O TRATAMENTO COM AQUALYX™''',
    texto: r'''DECLARO

Que a Médica Clara Jorge, com cédula profissional nº. 57166, me explicou que é conveniente, na minha situação clínica, proceder ao tratamento com AQUALYX™.

Conheço pessoalmente a Dra. e o seu título profissional; aceito que atua de forma responsável no meu tratamento. Reconheço e aceito a sua capacitação profissional para realizar o tratamento proposto.

A minha consulta com a Dra. Clara Jorge e a conversa com ela, teve uma duração suficiente para valorizar adequadamente e com tranquilidade a informação recebida, assim como os riscos e os benefícios do tratamento ao qual desejo submeter-me.

DESCRIÇÃO DO PROCEDIMENTO, NECESSIDADES E ALTERNATIVAS

O AQUALYX™ foi desenvolvido pelo renomado cirurgião estético Prof. Pasquale Motolese em 2002 e tem sido utilizado desde há muitos anos em diversos países da Comunidade Europeia e resto do mundo. Não ocorreu nenhum efeito colateral importante e o tratamento foi bem tolerado e bem-sucedido.

AQUALYX™ é uma solução injetável, hidratada, micro-gelatinosa, biocompatível e biodegradável que provoca a dissolução das células de gordura, após a aplicação o corpo expele naturalmente os ácidos gordos libertados. AQUALYX™ é um complexo contendo um detergente da família dos desoxicolatos que foi fisicamente modificado para reduzir a semi-vida biológica e possuir um sistema de liberação lenta à base de açúcar, a qual resulta em efeitos colaterais mínimos. Os ingredientes são um polímero de 3,6-anidro-L-galactose e D-Galactose, sistema tampão, sal de sódio de (3α, 5α, 12α) - 3, 12-dihidroxi-5-colan-24-ácido, água para fins de injeção e cloreto de sódio.

Durante a intralipoterapia, AQUALYXTM é injetado diretamente no tecido adiposo subcutâneo usando cânulas muito finas. Dentro das semanas seguintes as células de gordura tratadas são gradualmente dissolvidas. O metabolismo na área tratada fica aumentado.

A intralipoterapia é destinada a pacientes com tecido adiposo localizado que não responde à dieta ou aumento do exercício físico. A intralipoterapia não é destinada à perda de peso, é usada para melhorar e alterar o contorno corporal. Os resultados não podem ser comparados a uma lipoaspiração, pois a lipoaspiração é um método cirúrgico de redução de gordura onde grandes quantidades de gordura são removidas permanentemente do corpo.

Os resultados da intralipoterapia são permanentes, porém o procedimento leva tempo para atingir o seu pleno efeito. Nos pacientes que fizeram acompanhamento, os exames sete anos após a terapia ainda mostram uma diminuição relevante do tecido adiposo nas áreas tratadas.

A intralipoterapia é um tratamento estético-medicinal que geralmente não é reembolsável pelo governo ou por seguradoras de saúde privadas. O paciente deve arcar com todas as despesas.

A intralipoterapia pode ser utilizada como meio de redução moderada do tecido adiposo, bem como tratamento contra o lipoma benigno por pacientes que não se querem submeter à cirurgia. AQUALYX™ é injetado diretamente no tecido adiposo. Normalmente não é necessário administrar anestesia.

AUTORIZO a administração de sedação e/ou anestesia local ou bloqueio nervoso, administrada pelo médico que realiza o tratamento tal como convenha em cada caso

Até à data, não foi registado um único fenómeno de sobredosagem ou intoxicação.

Os intervalos entre os tratamentos devem ser de três a quatro semanas. A quantidade de tratamentos pode variar entre duas e oito sessões de acordo com as características da área tratada. Como apoio à terapia, pode ser administrado um tratamento de ultrassom localizado diretamente após a injeção. No entanto, o tratamento com ultrassom não é o fator decisivo no processo de redução de gordura desejada.

Como todas as terapias medicinais estéticas não há garantia de um tratamento totalmente bem-sucedido. Será necessário um mínimo de dois tratamentos.

Cerca de 1% dos pacientes tratados apresentaram efeitos nulos a mínimos após a intralipoterapia.

AQUALYX™ apresenta as seguintes contra-indicações absolutas: ser menor de idade, gravidez, amamentação, doente diabético com microangiopatia.

AQUALYX™ apresenta as seguintes contra-indicações relativas: doenças autoimunes (por exemplo, esclerodermia); hipersensibilidade aos ingredientes; doenças hepáticas graves; doença renal grave; infeções agudas e crónicas; alergias; adiposidade severa (IMC > 30); doenças de coagulação do sangue; distúrbios menstruais.

Fui informado sobre os seguintes efeitos adversos:

- Riscos gerais: a terapia de injeção pode resultar em danos permanentes do tecido nervoso e dos nervos, bem como inflamação, reações e infeções que podem resultar em cicatrizes irreversíveis.

- Efeitos adversos esperados: inchaço e hipertermia da área injetada, hematoma, sensibilidade à pressão, dor moderada e prurido na área tratada.

- Possíveis efeitos adversos: vermelhidão da pele que pode se tornar permanente, rigidez pontual permanente ou caroços dentro do tecido, depressões da área tratada devido à redução irregular das células de gordura, distúrbio vegetativo, bem como debilidade temporária do sistema circulatório (certifique-se de se hidratar bebendo uma quantidade suficiente de água), sudorese, náusea, diarreia (incomum), hemorragia menstrual intracíclica (mulheres), reações alérgicas (muito incomum) como urticária, asma brônquica, sintomas de choque, hiperpigmentação (pode durar vários meses).

17. RECONHEÇO que no curso do procedimento podem surgir condições não previstas e que seja necessária uma alteração do anteriormente planejado e dou aqui minha expressa autorização para o tratamento das mesmas. No caso de complicações durante o tratamento, autorizo a minha transferência a um centro hospitalar onde poderão realizar os procedimentos necessários.

Fui informado sobre terapias alternativas, como medidas dietéticas, aumento do exercício físico ou correção cirúrgica (por exemplo, lipoaspiração). Na presente data não considero nenhuma dessas opções.

Um controle clínico será realizado após a conclusão de todos os tratamentos agendados e após os intervalos de tempo designados.

Li este consentimento informado e certifico que compreendo o seu conteúdo na íntegra. Fui informado de que não devo aplicar qualquer tipo de cosméticos na área tratada nas primeiras doze horas após o tratamento com AQUALYX™ e que a exposição a fontes de calor durante os dias seguintes deve ser evitada (por exemplo, luz solar, radiação UV, sauna).

Estou ciente do fato que após a terapia com AQUALYX™ não devem ser administrados tratamentos com laser, Criolipólise ou terapia de radiofrequência. Além disso, devo me abster de exercícios físicos particularmente exigentes por sete dias.

Recebi uma cópia deste formulário de consentimento. O meu consentimento e autorização para este procedimento é estritamente voluntário. Ao assinar este formulário de consentimento informado, concedo autoridade ao meu médico para realizar intralipoterapia usando AQUALYX™ e administrar um tratamento de ultra-som adicional que possa ser considerado necessário ou aconselhável no diagnóstico e tratamento da minha condição. A natureza e finalidade deste procedimento, possíveis métodos alternativos de tratamento, bem como complicações foram totalmente explicados.

22. Nenhuma garantia foi dada por ninguém quanto aos resultados que podem ser obtidos por este tratamento.

14. COMPROMETO-ME a seguir fielmente, o melhor possível, as indicações da médica para antes, durante e depois do tratamento anteriormente mencionado. Ficando sob minha responsabilidade, o cumprimento das medidas pós-tratamento recomendadas.

15. CONFIRMO de não haver omitido ou alterado os meus dados e antecedentes clínico- cirúrgicos, especialmente os relacionados a alergias e doenças ou riscos pessoais.

16. AUTORIZO a que me pratiquem fotografias da zona tratada que poderão ser utilizadas com fins científicos, docentes ou médicos. Ficando entendido que o seu uso não constituirá nenhuma violação à intimidade ou confidencialidade, das que tenho direito.

17. INFORMARAM-ME que os meus dados serão tratados de forma automatizada, procedimento que autorizo, e foram-me explicados os meus direitos de conformidade com a lei vigente.

18. INFORMARAM-ME, igualmente, do meu direito de recusar o tratamento ou revogar este consentimento.

Tive tempo suficiente para considerar as informações do meu médico e sinto que estou suficientemente aconselhado a consentir com isso procedimento. Por meio deste, dou meu consentimento para este procedimento e fui solicitado a assinar este formulário após minha discussão com o médico.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_toxina',
    tipo: 'recomendacao',
    titulo: r'''Toxina botulínica''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - TOXINA BOTULÍNICA''',
    texto: r'''NAS PRIMEIRAS HORAS

- Permaneça em posição vertical e evite deitar-se ou baixar a cabeça durante as primeiras 4 horas.
- Não massaje, esfregue nem pressione a zona tratada nas primeiras 24 horas.
- Evite exercício físico intenso nas primeiras 24 horas.
- Evite fontes de calor intenso (sauna, banho turco, exposição solar prolongada) nas primeiras 24 a 48 horas.

O QUE É NORMAL

- Pequeno inchaço, vermelhidão ou uma pequena mancha roxa nos pontos de injeção, que desaparecem em poucos dias.
- O efeito começa habitualmente a notar-se entre 24 horas e 5 dias após o tratamento e mantém-se, em média, durante 4 a 8 meses.

QUANDO CONTACTAR A CLÍNICA

- Pálpebra ou sobrancelha descaída, assimetria marcada, dificuldade em engolir ou falar, falta de ar, ou qualquer alteração que a preocupe.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_hialuronico',
    tipo: 'recomendacao',
    titulo: r'''Ácido hialurónico''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - ÁCIDO HIALURÓNICO''',
    texto: r'''NAS PRIMEIRAS 24 A 48 HORAS

- Evite massajar ou pressionar a zona tratada, a menos que lhe tenha sido indicado.
- Evite exercício físico intenso, sauna, banho turco, exposição solar e fontes de calor intenso.
- Evite maquilhagem nas primeiras 12 horas.
- Pode aplicar frio local (gelo envolto num pano limpo) durante poucos minutos de cada vez, para reduzir o inchaço.
- Evite dormir sobre a zona tratada.

O QUE É NORMAL

- Inchaço, vermelhidão, sensibilidade e pequenas manchas roxas nos primeiros dias.
- Pequenas irregularidades ao toque que tendem a desaparecer nos dias seguintes.

QUANDO CONTACTAR COM URGÊNCIA

- Dor intensa que aumenta, pele muito pálida, acinzentada ou arroxeada, alterações da visão, ou sinais de infeção (calor, vermelhidão a aumentar, pus ou febre). Contacte a clínica de imediato ou recorra a um serviço de urgência.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_profhilo',
    tipo: 'recomendacao',
    titulo: r'''Profhilo''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - PROFHILO''',
    texto: r'''NAS PRIMEIRAS 24 A 48 HORAS

- Evite massajar ou pressionar os pontos de injeção, a menos que lhe tenha sido indicado.
- Evite exercício físico intenso, sauna, banho turco, exposição solar e fontes de calor intenso.
- Evite maquilhagem nas primeiras 12 horas.

O QUE É NORMAL

- Pequenas elevações (pápulas) nos pontos de injeção, vermelhidão ligeira e sensibilidade, que desaparecem nas horas ou dias seguintes.
- Pequenas manchas roxas ocasionais.

PRÓXIMAS SESSÕES

- O número de sessões e o intervalo entre elas serão indicados pela médica.

QUANDO CONTACTAR A CLÍNICA

- Se notar dor intensa e crescente, sinais de infeção (calor, vermelhidão a aumentar, pus ou febre) ou qualquer alteração que a preocupe, contacte a clínica.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_nctf',
    tipo: 'recomendacao',
    titulo: r'''NCTF HA (polirevitalização facial)''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - POLIREVITALIZAÇÃO FACIAL (NCTF HA)''',
    texto: r'''NAS PRIMEIRAS 24 A 48 HORAS

- Evite massajar ou esfregar a zona tratada.
- Evite exercício físico intenso, sauna, banho turco, exposição solar e fontes de calor intenso.
- Evite maquilhagem nas primeiras 12 a 24 horas.
- Mantenha a pele limpa e hidratada, apenas com os produtos recomendados.

O QUE É NORMAL

- Pequenas pápulas, vermelhidão, sensibilidade e pequenas manchas roxas nos pontos de injeção, nos primeiros dias.

PROTEÇÃO SOLAR

- Utilize protetor solar de amplo espectro todos os dias.

QUANDO CONTACTAR A CLÍNICA

- Se notar dor intensa e crescente, sinais de infeção (calor, vermelhidão a aumentar, pus ou febre) ou qualquer alteração que a preocupe, contacte a clínica.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_mesoterapia',
    tipo: 'recomendacao',
    titulo: r'''Mesoterapia''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - MESOTERAPIA''',
    texto: r'''NAS PRIMEIRAS 24 HORAS

- Evite massajar ou esfregar a zona tratada.
- Evite exercício físico intenso, sauna, banho turco e fontes de calor intenso.
- Evite maquilhagem e cosméticos na zona tratada nas primeiras 12 horas.

O QUE É NORMAL

- Pequenas pápulas, vermelhidão, dor ligeira e pequenas manchas roxas nos pontos de injeção, que desaparecem em poucos dias.

PROTEÇÃO SOLAR

- Evite a exposição solar direta e utilize protetor solar nos dias seguintes.

QUANDO CONTACTAR A CLÍNICA

- Se notar dor intensa e crescente, sinais de infeção (calor, vermelhidão a aumentar, pus ou febre) ou qualquer alteração que a preocupe, contacte a clínica.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_microneedling',
    tipo: 'recomendacao',
    titulo: r'''Microneedling''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - MICRONEEDLING''',
    texto: r'''NAS PRIMEIRAS 24 A 48 HORAS

- Lave a pele com água morna e um produto suave, sem esfregar.
- Aplique apenas os produtos de hidratação e reparação recomendados.
- Evite maquilhagem nas primeiras 24 horas.
- Evite exercício físico intenso, sauna, banho turco, piscina e fontes de calor intenso.

O QUE É NORMAL

- Vermelhidão semelhante a uma queimadura solar ligeira, tensão e pequenas descamações nos primeiros dias.
- Não arranque nem esfregue as pequenas crostas ou descamações; deixe-as cair naturalmente.

PROTEÇÃO SOLAR

- Utilize protetor solar de amplo espectro todos os dias e evite a exposição solar direta.
- Evite esfoliantes, ácidos e retinoides até indicação da médica.

QUANDO CONTACTAR A CLÍNICA

- Se notar dor intensa e crescente, sinais de infeção (calor, vermelhidão a aumentar, pus ou febre) ou qualquer alteração que a preocupe, contacte a clínica.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_peeling',
    tipo: 'recomendacao',
    titulo: r'''Peeling químico''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - PEELING QUÍMICO''',
    texto: r'''NOS DIAS SEGUINTES

- Utilize apenas os produtos de limpeza e hidratação recomendados.
- Não retire a pele que descama; deixe-a cair naturalmente.
- Evite esfoliantes, ácidos, retinoides e outros produtos irritantes até indicação da médica.
- Evite sauna, banho turco, piscina e exercício físico que provoque muito suor nas primeiras 48 horas.

O QUE É NORMAL

- Vermelhidão, sensação de tensão e descamação nos dias seguintes, variável consoante o tipo de peeling.

PROTEÇÃO SOLAR

- Utilize protetor solar de amplo espectro todos os dias e evite a exposição solar direta.

QUANDO CONTACTAR A CLÍNICA

- Se notar dor intensa e crescente, sinais de infeção (calor, vermelhidão a aumentar, pus ou febre) ou qualquer alteração que a preocupe, contacte a clínica.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_fios',
    tipo: 'recomendacao',
    titulo: r'''Fios tensores''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - FIOS TENSORES''',
    texto: r'''NAS PRIMEIRAS SEMANAS

- Evite movimentos faciais exagerados (bocejar muito, gargalhar, abrir muito a boca).
- Durma de barriga para cima, com a cabeça ligeiramente elevada.
- Evite massagens, tratamentos faciais, sauna, banho turco e exercício físico intenso, conforme indicação da médica.
- Mantenha uma higiene suave da zona tratada, sem esfregar.

O QUE É NORMAL

- Sensação de tensão, inchaço, pequenas manchas roxas e algum desconforto nos primeiros dias.

QUANDO CONTACTAR A CLÍNICA

- Dor intensa, sinais de infeção, assimetria marcada, fio visível ou palpável, ou qualquer alteração que a preocupe.''',
    atualizadoEm: _agora,
  ),
  Modelo(
    id: 'r_aqualyx',
    tipo: 'recomendacao',
    titulo: r'''Aqualyx (intralipoterapia)''',
    tituloDoc: r'''RECOMENDAÇÕES PÓS-TRATAMENTO - AQUALYX''',
    texto: r'''APÓS O TRATAMENTO

- Não aplique cosméticos na zona tratada nas primeiras 12 horas.
- Evite fontes de calor nos dias seguintes (luz solar, radiação UV, sauna).
- Evite exercício físico particularmente exigente durante 7 dias.
- Não faça tratamentos com laser, criolipólise ou radiofrequência na zona tratada.
- Beba água em quantidade suficiente.

O QUE É NORMAL

- Inchaço e calor na zona injetada, hematoma, sensibilidade à pressão, dor moderada e comichão.

PRÓXIMAS SESSÕES

- Os intervalos entre tratamentos devem ser de três a quatro semanas, conforme indicação da médica.

QUANDO CONTACTAR A CLÍNICA

- Se notar dor intensa e crescente, sinais de infeção (calor, vermelhidão a aumentar, pus ou febre) ou qualquer alteração que a preocupe, contacte a clínica.''',
    atualizadoEm: _agora,
  ),
];
