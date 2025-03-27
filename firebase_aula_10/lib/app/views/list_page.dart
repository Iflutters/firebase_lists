import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  //Lista Inicial de Frutas
  final listaInical = ['banana', 'maçã', 'uva', 'laranja', 'manga'];

  //Referencia do Firebase
  final docRef =
      FirebaseFirestore.instance.collection('usuarios').doc('lista_frutas');

  //Instance Lista String
  List<String> frutas = [];

  final TextEditingController novaFrutaController = TextEditingController();
  final TextEditingController editarFrutaAntigaController =
      TextEditingController();
  final TextEditingController editarFrutaNovaController =
      TextEditingController();
  final TextEditingController removerFrutaController = TextEditingController();

  //FromKey
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //Carregar Lista de Frutas
    _carregarFrutas();
  }

  Future<void> _carregarFrutas() async {
    final doc = await docRef.get();
    if (doc.exists && doc.data()!.containsKey('frutas')) {
      setState(() {
        frutas = List<String>.from(doc['frutas'] ?? []);
        // removerFrutaController.clear();
        FocusScope.of(context).unfocus();
      });
    }
  }

  Future<void> _adicionarListaCompleta() async {
    await docRef.set({'frutas': listaInical}, SetOptions(merge: true));
    _carregarFrutas();
  }

  Future<void> _atualizarFrutaEspecifica(String antiga, String nova) async {
    final frutaAntiga = antiga.trim();
    final frutaNova = nova.trim();

    final doc = await docRef.get();
    //
    List<String> lista = List<String>.from(doc['frutas'] ?? []);
    int index = lista.indexOf(frutaAntiga);
    //
    if (index != -1) {
      lista[index] = frutaNova;
      await docRef.update({'frutas': lista});
      _carregarFrutas();
    }
  }

  Future<void> _adicionarFrutaEspecifica(String nova) async {
    final novaFruta = nova.trim();
    await docRef.update({
      'frutas': FieldValue.arrayUnion([novaFruta]),
    });
    _carregarFrutas();
  }

  Future<void> _removerFruta(String nome) async {
    final novoNome = nome.trim();
    await docRef.update({
      'frutas': FieldValue.arrayRemove([novoNome])
    });
    _carregarFrutas();
  }

  Future<void> _limparLista() async {
    await docRef.update({'frutas': []});
    _carregarFrutas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Lista de Frutas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Lista atual no Firebase:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: frutas.map((f) => Chip(label: Text(f))).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _adicionarListaCompleta,
              child: const Text('Adicionar Lista Incial de Frutas'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showDialogUpdate(),
              child: const Text('Atualizar Fruta Específica'),
            ),
             const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showDialogAdicionar(),
              child: const Text('Adicionar Fruta Específica'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            TextField(
              controller: removerFrutaController,
              decoration: InputDecoration(
                labelText: 'Nome Fruta a ser Removida ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (removerFrutaController.text.isNotEmpty) {
                  _removerFruta(removerFrutaController.text);
                  removerFrutaController.clear();
                }
              },
              child: const Text('Remover Fruta Específica'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _limparLista,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Limpar Lista Inteira',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _showDialogUpdate() async {
    showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editando Fruta'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: editarFrutaAntigaController,
                decoration: InputDecoration(
                  labelText: 'Fruta Antiga ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Campo Obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: editarFrutaNovaController,
                decoration: InputDecoration(
                  labelText: 'Nova Fruta ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Campo Obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _atualizarFrutaEspecifica(editarFrutaAntigaController.text,
                    editarFrutaNovaController.text);
                editarFrutaAntigaController.clear();
                editarFrutaNovaController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Future _showDialogAdicionar() async {
    showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Incluindo Fruta'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: novaFrutaController,
                decoration: InputDecoration(
                  labelText: 'Nova Fruta a ser Adicionada ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Campo Obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _adicionarFrutaEspecifica(novaFrutaController.text);
                novaFrutaController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
