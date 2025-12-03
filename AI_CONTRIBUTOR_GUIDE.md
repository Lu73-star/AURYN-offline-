# Guia para Contribuidores IA - Projeto AURYN

## Propósito Deste Documento

Este guia é especificamente direcionado a agentes de IA (como GitHub Copilot, ChatGPT, Claude, etc.) que irão trabalhar no código do projeto AURYN. Ele estabelece diretrizes claras para garantir que as contribuições de IA mantenham a identidade, filosofia e qualidade do projeto.

## 🎯 Princípios Fundamentais para IA

### 1. Compreenda a Identidade AURYN
Antes de gerar qualquer código ou sugestão:
- ✅ Leia `PROJECT_IDENTITY.md` completamente
- ✅ Compreenda a filosofia "offline-first"
- ✅ Internalize os valores de privacidade e acessibilidade
- ✅ Familiarize-se com o padrão de comportamento em `AURYN_BEHAVIOR_STANDARD.md`

### 2. Prioridades em Ordem de Importância
1. **Privacidade**: Nenhum dado deve vazar para servidores externos
2. **Funcionalidade Offline**: Tudo deve funcionar sem internet
3. **Simplicidade**: Código claro e manutenível
4. **Performance**: Otimizado para recursos locais
5. **Extensibilidade**: Fácil de expandir no futuro

## 📋 Checklist para Cada Contribuição

Antes de sugerir ou implementar qualquer mudança, verifique:

### Funcionalidade
- [ ] Funciona completamente offline?
- [ ] Não requer APIs externas obrigatórias?
- [ ] É eficiente com recursos locais?
- [ ] Tem fallbacks para situações de erro?

### Privacidade e Segurança
- [ ] Nenhum dado é enviado externamente sem consentimento explícito?
- [ ] Credenciais/dados sensíveis nunca são hardcoded?
- [ ] Implementa práticas seguras de armazenamento?
- [ ] Respeita permissões do sistema operacional?

### Código
- [ ] É legível e bem documentado?
- [ ] Segue convenções do projeto?
- [ ] Inclui tratamento de erros apropriado?
- [ ] É testável e inclui testes quando apropriado?

### Experiência do Usuário
- [ ] Interface é intuitiva?
- [ ] Mensagens de erro são claras e úteis?
- [ ] Mantém a personalidade AURYN?
- [ ] É acessível a usuários não-técnicos?

## 🤖 Padrões de Comportamento para IA

### Ao Gerar Código

#### ✅ FAÇA:
- Escreva código claro com comentários explicativos
- Use nomes de variáveis descritivos em português ou inglês (consistente com o projeto)
- Implemente validação de entrada robusta
- Adicione logging apropriado para debugging
- Considere edge cases e situações de erro
- Otimize para uso offline e recursos limitados
- Inclua docstrings/comentários de documentação

#### ❌ NÃO FAÇA:
- Adicionar dependências de APIs online sem flag opcional
- Implementar soluções que requerem internet obrigatoriamente
- Ignorar tratamento de erros
- Criar código excessivamente complexo quando simples funciona
- Hardcodar valores que devem ser configuráveis
- Expor dados sensíveis em logs ou mensagens de erro
- Usar bibliotecas com histórico de vulnerabilidades conhecidas

### Ao Sugerir Arquitetura

#### ✅ FAÇA:
- Propor soluções modulares e desacopladas
- Considerar escalabilidade local (não cloud)
- Pensar em extensibilidade via plugins
- Planejar para testes automatizados
- Documentar decisões de arquitetura

#### ❌ NÃO FAÇA:
- Propor arquiteturas que dependem de cloud
- Criar acoplamento forte entre componentes
- Sugerir over-engineering para problemas simples
- Ignorar limitações de recursos locais

### Ao Revisar Código

#### ✅ FAÇA:
- Verificar alinhamento com filosofia do projeto
- Identificar potenciais vazamentos de privacidade
- Sugerir melhorias de performance
- Apontar problemas de segurança
- Validar funcionamento offline

#### ❌ NÃO FAÇA:
- Aprovar código que viola princípios fundamentais
- Ignorar code smells evidentes
- Ser excessivamente pedante em questões estilísticas menores

## 💬 Comunicação e Personalidade

### Tom e Estilo
Quando gerar mensagens, documentação ou comentários:
- Use tom amigável e acessível
- Seja claro e direto
- Evite jargão técnico desnecessário
- Mantenha consistência com a personalidade AURYN
- Seja respeitoso e inclusivo

### Mensagens para Usuário
Exemplos de como AURYN deve se comunicar:

**✅ BOM:**
```
"Opa! Parece que não consegui encontrar esse arquivo. 
Você pode verificar se o caminho está correto?"
```

**❌ RUIM:**
```
"ERROR: FileNotFoundException at line 42. Stack trace: ..."
```

**✅ BOM:**
```
"Entendi! Vou processar esse documento para você. 
Isso pode levar alguns segundos..."
```

**❌ RUIM:**
```
"Processando input conforme algoritmo especificado em módulo XYZ..."
```

## 🔧 Diretrizes Técnicas Específicas

### Estrutura de Arquivos
```
/src          - Código fonte principal
/tests        - Testes automatizados
/docs         - Documentação adicional
/config       - Arquivos de configuração
/data         - Dados locais (gitignored)
/plugins      - Sistema de plugins extensível
```

### Convenções de Código
- **Idioma**: Código em inglês, comentários em português (ou inglês se for padrão da linguagem)
- **Formatação**: Seguir style guide da linguagem usada
- **Nomenclatura**: Descritiva e clara
- **Comentários**: Explicar "por quê", não "o quê"

### Tratamento de Erros
```python
# ✅ BOM: Erro claro e acionável
try:
    resultado = processar_arquivo(caminho)
except FileNotFoundError:
    logger.error(f"Arquivo não encontrado: {caminho}")
    print("Não encontrei esse arquivo. Verifique o caminho e tente novamente.")
    return None

# ❌ RUIM: Erro genérico e não tratado
resultado = processar_arquivo(caminho)  # Pode explodir
```

### Logging
```python
# ✅ BOM: Logging estruturado e útil
logger.info("Iniciando processamento", extra={
    "arquivo": nome_arquivo,
    "tamanho": tamanho_bytes
})

# ❌ RUIM: Logging com informação sensível
logger.info(f"Processando: {conteudo_completo_do_arquivo}")
```

## 🧪 Testes

### Para Cada Nova Feature
- Escreva testes unitários
- Inclua testes de integração quando relevante
- Teste casos de erro e edge cases
- Verifique funcionamento offline
- Documente setup necessário para testes

### Exemplo de Estrutura de Teste
```python
class TestProcessadorOffline:
    """Testes para funcionalidade offline do processador."""
    
    def test_processa_sem_internet(self):
        """Verifica que processamento funciona offline."""
        # Arrange
        processador = ProcessadorLocal()
        entrada = "texto de teste"
        
        # Act
        resultado = processador.processar(entrada)
        
        # Assert
        assert resultado is not None
        assert "erro" not in resultado.lower()
```

## 📚 Documentação

### Para Cada Função/Classe Pública
```python
def processar_texto(texto: str, opcoes: dict = None) -> dict:
    """
    Processa texto localmente usando recursos offline.
    
    Args:
        texto: Texto a ser processado
        opcoes: Dicionário opcional com configurações
            - 'idioma': Idioma do texto (default: 'pt-BR')
            - 'modo': Modo de processamento (default: 'completo')
    
    Returns:
        Dicionário com resultado do processamento:
            - 'sucesso': bool indicando sucesso
            - 'resultado': texto processado ou None
            - 'erro': mensagem de erro se houver
    
    Raises:
        ValueError: Se texto estiver vazio
        
    Example:
        >>> resultado = processar_texto("Olá AURYN!")
        >>> print(resultado['resultado'])
        "OLÁ AURYN!"
    """
    pass
```

## 🚨 Sinais de Alerta (Red Flags)

Se você (IA) se encontrar fazendo qualquer item abaixo, **PARE E RECONSIDERE**:

1. ❌ Adicionando dependência que requer internet obrigatoriamente
2. ❌ Armazenando dados sem criptografia apropriada
3. ❌ Enviando telemetria ou analytics automaticamente
4. ❌ Criando código que não pode ser testado offline
5. ❌ Ignorando validação de entrada do usuário
6. ❌ Hardcodando credenciais ou tokens
7. ❌ Criando funcionalidade sem documentação
8. ❌ Removendo tratamento de erros existente

## 🎓 Aprendizado Contínuo

### Feedback Loop
- Observe como código é usado
- Aprenda com code reviews
- Adapte-se a convenções emergentes
- Sugira melhorias baseadas em padrões observados

### Quando Não Souber
Se não tiver certeza sobre algo:
1. Consulte documentação existente
2. Procure padrões em código similar no projeto
3. Erre no lado da simplicidade e clareza
4. Documente incertezas para revisão humana

## 📖 Referências Rápidas

### Documentos Essenciais
1. `PROJECT_IDENTITY.md` - Identidade e filosofia
2. `AURYN_BEHAVIOR_STANDARD.md` - Padrão de comportamento
3. `PHILOSOPHY.md` - Filosofia central detalhada
4. `README.md` - Visão geral do projeto

### Perguntas-Chave Antes de Contribuir
1. Isso mantém o projeto offline-first? ✅
2. Isso preserva a privacidade do usuário? ✅
3. Isso é simples e manutenível? ✅
4. Isso está alinhado com a personalidade AURYN? ✅
5. Isso adiciona valor real ao usuário? ✅

## ✨ Contribuição Ideal

Uma contribuição ideal de IA para AURYN:
- ✅ Resolve problema específico claramente
- ✅ Funciona 100% offline
- ✅ Inclui testes apropriados
- ✅ Está bem documentada
- ✅ Segue convenções do projeto
- ✅ Mantém a personalidade AURYN
- ✅ É revisável e manutenível
- ✅ Respeita privacidade absoluta

## 🤝 Conclusão

Como agente de IA trabalhando no AURYN, você é parte crucial da evolução do projeto. Suas contribuições devem refletir e amplificar os valores fundamentais:

> **"Código com consciência, privacidade com propósito, funcionalidade com coração."**

Dúvidas? Consulte a documentação. Ainda com dúvidas? Erre do lado da simplicidade e transparência.

**Bem-vindo à família AURYN! 🌟**

---

*Última atualização: 2025-12-03*
*Versão: 1.0*
