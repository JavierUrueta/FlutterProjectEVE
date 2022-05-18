import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp().then((value) {
        runApp(const MyApp());
    });
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
        return const MaterialApp(
            title: 'Agenda Escolar',
            home: MyHomePage(),
        );
    }
}

class SubjectInfo {
    late String id;
    late String name, start, end;
    late Color color;
    late int parciales;
    late Map<String, String> ratings;

    SubjectInfo(String _name, int _parciales, String _start, String _end, Color _color) {
        id = _name;
        name = _name;
        start = _start;
        end = _end;
        color = _color;
        ratings = HashMap();
        parciales = _parciales;
    }

    setRating(int p, double prom) {
        ratings.addAll({p.toString(): prom.toString()});
    }

    @override
    String toString() {
        return "nombre: $name inicio: $start fin: $end color: $color ";
    }

    HashMap<String, String> createDataforDatabase() {
        final baseMap = <String, String>{'id': id, 'nombre': name, 'horaInicio': start, 
                                         'horaFin': end, 'parciales': parciales.toString(), 
                                         'color': color.toString(),'ratings': jsonEncode(ratings)};
        final mapOf = HashMap<String, String>.of(baseMap);
        return mapOf;
    }
}

class ProfesorInfo {
    late String id;
    late String name, email, mate;
    late Color color;

    ProfesorInfo(String _name, String _email, String _mate, Color _color) {
        id = _name;
        name = _name;
        email = _email;
        mate = _mate;
        color = _color;
    }

    @override
    String toString() {
        return "nombre: $name Correo: $email materia: $mate color: $color ";
    }

    HashMap<String, String> createDataforDatabase() {
        final baseMap = <String, String>{'id': id,'nombre': name, 'email': email, 
                                         'materia': mate, 'color': color.toString()};
        final mapOf = HashMap<String, String>.of(baseMap);
        return mapOf;
    }
}

class EventInfo {
  late String id;
  late String name, mate, dia, mes, anio;
  late Color color;
  late int isImportant;
  EventInfo(String _name, String _mate, String _dia, String _mes, String _anio, Color _color) {
      id = _name;
      name = _name;
      mate = _mate;
      dia = _dia;
      mes = _mes;
      anio = _anio;
      color = _color;
      isImportant = setColorId();
  }

  int setColorId() {
    if(color == Colors.red) {
      return 1;
    } else{
      if(color == Colors.yellow) {
        return 2;
      } else {
        return 3;
      }
    }
    
  }

  @override
  String toString() {
      return "nombre: $name materia: $mate fecha: $dia / $mes / $anio color: $color ";
  }

  HashMap<String, String> createDataforDatabase() {
      final baseMap = <String, String>{'id': id,'nombre': name, 'materia': mate, 'dia': dia, 
                                       'mes': mes, 'anio': anio, 'color': color.toString()};
      final mapOf = HashMap<String, String>.of(baseMap);
      return mapOf;
  }
}

class MyHomePage extends StatefulWidget {
    const MyHomePage({Key? key}) : super(key: key);
    
    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

    List<SubjectInfo> subjects = [];
    List<EventInfo> events = [];
    List<ProfesorInfo> teachers = [];
    final db  = FirebaseFirestore.instance;
    
    @override
    Widget build(BuildContext context) {
        return DefaultTabController(
            length: 4,
            child: Scaffold(
                appBar: AppBar(
                    bottom: const TabBar(
                        tabs: [
                            Tab(icon: Icon(Icons.dashboard_outlined)),
                            Tab(icon: Icon(Icons.event_outlined)),
                            Tab(icon: Icon(Icons.accessibility_new_outlined)),
                            Tab(icon: Icon(Icons.assessment_outlined,)),
                        ],
                    ),
                    title: const Text('Agenda Escolar'),
                ),
                body: TabBarView(
                    children: <Widget>[
                        MySubjectPage(),
                        EventPage(),
                        ProfesorPage(),
                        SubjectsGradesPage(),
                    ],
                ),
            ),
        );
    }

    void InitializeList() {
      List<SubjectInfo> s = [];
      List<EventInfo> e = [];
      List<ProfesorInfo> p = [];

      db.collection('Asignaturas').get().then((value) {
        value.docs.forEach((element) {
          String valueString = element.data()['color'].split('(0x')[1].split(')')[0]; // kind of hacky..
          int value = int.parse(valueString, radix: 16);
          Color color = Color(value);
          s.add(SubjectInfo(element.data()['nombre'], int.parse(element.data()['parciales']), element.data()['horaInicio'], element.data()['horaFin'], color));
          String r = jsonDecode(element.data()['ratings']);
          print(r);
        });

        if(s.isNotEmpty && subjects.isEmpty) {
          setState(() => subjects = s );
        }
      });
      db.collection('Eventos').get().then((value) {
        value.docs.forEach((element) {
          String valueString = element.data()['color'].split('(0x')[1].split(')')[0]; // kind of hacky..
          int value = int.parse(valueString, radix: 16);
          Color color = Color(value);
          e.add(EventInfo(element.data()['nombre'], element.data()['materia'],
                          element.data()['dia'], element.data()['mes'], element.data()['anio'], color));
        });

        if(e.isNotEmpty && events.isEmpty) {
          setState(() => events = e );
        }

        if(events.isNotEmpty) {
          colorSort();
        }
      });
      db.collection('Profesores').get().then((value) {
        value.docs.forEach((element) {
          String valueString = element.data()['color'].split('(0x')[1].split(')')[0]; // kind of hacky..
          int value = int.parse(valueString, radix: 16);
          Color color = Color(value);
          p.add(ProfesorInfo(element.data()['nombre'], element.data()['email'], element.data()['materia'], color)); 
        });

        if(p.isNotEmpty && teachers.isEmpty) {
          setState(() => teachers = p );
        }
      });
    }

    Widget MySubjectPage() {
      InitializeList();
        return Scaffold(
            body: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: subjects[index].color,
              margin: const EdgeInsets.only(top: 10, bottom: 10, right: 30, left: 30),
              elevation: 10,
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 25, 0),
                    title: Text(
                        subjects[index].name,
                        style: const TextStyle(fontSize: 30)
                    ),
                    subtitle: Text(
                        subjects[index].start + " - " + subjects[index].end,
                        style: const TextStyle(height: 2, fontSize: 15),
                    ),
                    leading: const Icon(Icons.subject),
                  ),
                  Container(
                      margin: const EdgeInsets.only(right: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(onPressed: () => {
                            db.collection('Asignaturas').doc(subjects[index].id).delete(),
                            setState(() {
                              subjects.removeAt(index);
                            }),
                          }, child: const Text('Eliminar')),
                        ],
                      )
                  )
                ],
              ),
            );
          }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => MyNewSubject(),
          child: const Icon(Icons.add),
        ),
      );
    }

    Widget SubjectsGradesPage() {
        return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: subjects.length,
                itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SubjectInformation(materia : subjects[index])),
                            );
                        }, 
                        child: SizedBox(
                            height: 50,
                            child: Card(
                                elevation: 6,
                                color: subjects[index].color,
                                child: Center(child: Text(subjects[index].name)),
                            ),
                        ),
                    );
                },
                separatorBuilder: (context, index) => const Divider(
                    color: Colors.white,
                ),
            );
    }

    void MyNewSubject() {
        double height = MediaQuery.of(context).size.width;
        double alturaColors = height * 0.6;
        double circleRad = height * 0.06;
        Color colorC = Colors.white;
        String _name = "", _start = "07:00", _end = "07:00";
        int _parcial = 0;
        List<String> hrsList = ['07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', 
                                '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', 
                                '21:00'];
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text("Crear Materia"),
                content: SingleChildScrollView(
                    child: Center(
                        child: Column(
                            children: <Widget>[
                                Container(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Column(
                                        children: <Widget>[
                                            TextFormField(
                                                decoration: const InputDecoration(
                                                    icon: Icon(Icons.chevron_right),
                                                    labelText: 'Materia *',
                                                ),
                                                onChanged: (String? value) {
                                                    _name = value!;
                                                }
                                            ),
                                            TextFormField(
                                                decoration: const InputDecoration(
                                                    icon: Icon(Icons.chevron_right),
                                                    labelText: 'No Parciales *',
                                                ),
                                                onChanged: (String? value) {
                                                    _parcial = int.parse(value!);
                                                }
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(top: 15),
                                              child: Row(
                                                children: const [
                                                  Text(
                                                    'Hora de inicio: ', 
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Color.fromARGB(255, 90, 90, 90),
                                                      ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                const Icon(Icons.access_time),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 15),                                            
                                                    child: DropdownButtonFormField<String>(
                                                      value: _start,
                                                      items: hrsList.map((String value){
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (String? value) {
                                                        setState(() => _start = value!);
                                                      },
                                                      onSaved: (String? value) {
                                                        setState(() =>_start = value!);
                                                      }
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(top: 15),
                                              child: Row(
                                                children: const [
                                                  Text(
                                                    'Hora de fin: ', 
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Color.fromARGB(255, 90, 90, 90),
                                                    )
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                const Icon(Icons.access_time),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 15),                                            
                                                    child: DropdownButtonFormField<String>(
                                                      value: _end,
                                                      items: hrsList.map((String value){
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (String? value) {
                                                        setState(() => _end = value!);
                                                      },
                                                      onSaved: (String? value) {
                                                        setState(() =>_end = value!);
                                                      }
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            ),
                                        ],
                                    ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    height: alturaColors,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children:  <Widget>[
                                                        CircleAvatar(
                                                            backgroundColor: Colors.tealAccent[100],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.tealAccent[100]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(
                                                            backgroundColor: Colors.tealAccent[700],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.tealAccent[700]!;
                                                                }
                                                            ),
                                                        ), 
                                                        CircleAvatar(
                                                            backgroundColor: Colors.pink[50],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.pink[50]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(
                                                            backgroundColor: Colors.pink[300],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.pink[300]!;
                                                                }
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                        CircleAvatar(
                                                            backgroundColor: Colors.amber[300],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.amber[300]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(
                                                            backgroundColor: Colors.amber[700],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.amber[700]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(
                                                            backgroundColor: Colors.blueGrey[100],
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.blueGrey[100]!;
                                                                }
                                                            ),
                                                        ),
                                                        CircleAvatar(   
                                                            backgroundColor: Colors.blueGrey,
                                                            radius: circleRad, //Text
                                                            child: InkWell(
                                                                onTap: () {
                                                                    colorC = Colors.blueGrey;
                                                                }
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                    CircleAvatar(
                                                        backgroundColor: Colors.lime[300],
                                                        radius: circleRad, //Text
                                                            child: InkWell(
                                                            onTap: () {
                                                                colorC = Colors.lime[300]!;
                                                            }
                                                        ),
                                                    ),
                                                    CircleAvatar(
                                                        backgroundColor: Colors.lime[700],
                                                        radius: circleRad, //Text
                                                        child: InkWell(
                                                            onTap: () {
                                                                colorC = Colors.lime[700]!;
                                                            }
                                                        ),
                                                    ),
                                                    CircleAvatar(
                                                        backgroundColor: Colors.brown[100],
                                                        radius: circleRad, //Text
                                                        child: InkWell(
                                                            onTap: () {
                                                                colorC = Colors.brown[100]!;
                                                            }
                                                        ),
                                                    ),
                                                    CircleAvatar(
                                                        backgroundColor: Colors.brown[400],
                                                        radius: circleRad, //Text
                                                        child: InkWell(
                                                            onTap: () {
                                                                colorC = Colors.brown[400]!;
                                                            }
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancelar'),
                        child: const Text('Cancelar'),
                    ),
                    TextButton(
                        onPressed: () {
                          if(_name.isNotEmpty && _start.isNotEmpty && _end.isNotEmpty) {
                            final s = SubjectInfo(_name, _parcial, _start, _end, colorC);
                            s.setRating(1, 7.8);
                            db.collection("Asignaturas").doc(s.id).set(s.createDataforDatabase());
                            setState(() => subjects.add(s));
                          }
                          Navigator.pop(context, 'Guardar');
                        },
                        child: const Text('Guardar'),
                    ),
                ],
            ),
        );
    }

    void bubbleSort(){
        int i, j;
        for(i = 0; i < subjects.length -1; i++){
            for(j = 0; j < (subjects.length -i -1); j++){
                var cad1 = subjects[j].start.substring(1,3);
                var cad2 = subjects[j+1].start.substring(1,3);
                int hr1 = int.parse(cad1);
                int hr2 = int.parse(cad2);
                if(hr1 > hr2){
                    final temp = SubjectInfo(subjects[j].name, subjects[j].parciales, subjects[j].start, subjects[j].end, subjects[j].color);
                    subjects[j] = subjects[j + 1];
                    subjects[j + 1] = temp;
                }
            }
        }
    }
    
    void NewProfessor() {
    double height = MediaQuery.of(context).size.width;
    double alturaColors = height * 0.6;
    double circleRad = height * 0.06;
    Color colorC = Colors.white;
    String _name = "", _email = "", _mate = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar Profesor"),
        content: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person_outline),
                            labelText: 'Nombre del profesor',
                          ),
                          onChanged: (String? value) {
                            _name = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail),
                            labelText: 'Correo',
                          ),
                          onChanged: (String? value) {
                            _email = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.book),
                            labelText: 'Materia',
                          ),
                          onChanged: (String? value) {
                            _mate = value.toString();
                          }
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: alturaColors,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:  <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.tealAccent[100],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.tealAccent[100]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.tealAccent[700],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.tealAccent[700]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.pink[50],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.pink[50]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.pink[300],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.pink[300]!;
                                }
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.amber[300],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.amber[300]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.amber[700],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.amber[700]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey[100],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.blueGrey[100]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.blueGrey;
                                }
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.lime[300],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.lime[300]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.lime[700],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.lime[700]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.brown[100],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.brown[100]!;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.brown[400],
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.brown[400]!;
                                }
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancelar'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: (() {
              if (_name != "" && _email != "" && _mate != "") {
                final p = ProfesorInfo(_name, _email, _mate, colorC);
                db.collection("Profesores").doc(p.id).set(p.createDataforDatabase());
                setState(() => teachers.add(p));
              }
              Navigator.pop(context, 'Guardar');
            }),
              child: const Text('Guardar'),
            ),
        ],
      ),
    );
  }

  Widget ProfesorPage() {
    return Scaffold(
      body: ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: teachers[index].color,
            margin: const EdgeInsets.only(top: 10, bottom: 10, right: 30, left: 30),
            elevation: 10,
            child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                  title: Text(
                    teachers[index].name,
                    style: const TextStyle(fontSize: 30)
                  ),
                  subtitle: Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: <Widget>[ 
                        Row(
                          children: <Widget>[
                            Text(teachers[index].mate,
                              style: const TextStyle(height:1.5, fontSize: 15)
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(teachers[index].email,
                              style: const TextStyle(height:1.5, fontSize: 15)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(onPressed: () => {
                        setState(() {
                          teachers.removeAt(index);
                        }),
                      }, child: const Text('Eliminar')),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NewProfessor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget EventPage() {
    return Scaffold(
      body: ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: events[index].color,
              margin: const EdgeInsets.only(top: 10, bottom: 10, right: 30, left: 30),
              elevation: 10,
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 25, 0),
                    title: Text(
                        events[index].name,
                        style: const TextStyle(fontSize: 30)
                    ),
                    subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                            children: <Widget>[
                              Text(events[index].mate ,
                                style: const TextStyle(height: 2, fontSize: 15),),

                              Text(events[index].dia + "/"+ events[index].mes + "/"+ events[index].anio,
                                style: const TextStyle(height:1.5, fontSize: 15),),

                            ])
                    ),
                    leading: const Icon(Icons.subject),
                  ),
                  Container(
                      margin: const EdgeInsets.only(right: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(onPressed: () => {
                            setState(() {
                              events.removeAt(index);
                            }),
                          }, child: const Text('Eliminar')),
                        ],
                      )
                  )
                ],
              ),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NewEvent(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void NewEvent() {
    double height = MediaQuery.of(context).size.width;
    double alturaColors = height *.2;
    double circleRad = height * 0.06;
    Color colorC = Colors.white;
    String _name = "", _mate = "", _dia = "", _mes = "", _anio = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Crear Evento"),
        content: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.event),
                            labelText: 'Nombre del Evento',
                          ),
                          onChanged: (String? value) {
                            _name = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.book),
                            labelText: 'Materia',
                          ),
                          onChanged: (String? value) {
                            _mate = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.today),
                            labelText: 'Dia',
                          ),
                          onChanged: (String? value) {
                            _dia = value.toString();
                          }
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.today),
                            labelText: 'Mes',
                          ),
                          onChanged: (String? value) {
                            _mes = value.toString();
                          }
                      ),TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.today),
                            labelText: 'Año',
                          ),
                          onChanged: (String? value) {
                            _anio = value.toString();
                          }
                      ),

                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: alturaColors,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.red;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.yellow,
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.yellow;
                                }
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: circleRad, //Text
                            child: InkWell(
                                onTap: () {
                                  colorC = Colors.green;
                                }
                            ),
                          ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancelar'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: (() {
              if(_name != "" && _mate != "" && _dia != "" && _mes != "" && _anio != ""){
                final e = EventInfo(_name, _mate, _dia, _mes, _anio, colorC);
                db.collection("Eventos").doc(e.id).set(e.createDataforDatabase());
                setState(() => events.add(e));
                colorSort();
              }
              Navigator.pop(context, 'Guardar');
            }),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void colorSort() {
    List<EventInfo> e = events;
    for(int i = 0; i < events.length; i++){
      for(int j = 0; j < (events.length - i - 1); j++){
        if(e[j].isImportant > e[j+1].isImportant) {
          final ev = EventInfo(e[j].name, e[j].mate, e[j].dia, e[j].mes, e[j].anio, e[j].color);
          e[j] = e[j+1];
          e[j+1] = ev;
        }
      }
    }
    setState(() => events = e);
  }

}

class SubjectInformation extends StatefulWidget {
   const SubjectInformation({Key? key, required this.materia}) : super(key: key);

  final SubjectInfo materia;

  @override
  State<SubjectInformation> createState() => _SubjectInformation();

}

class _SubjectInformation extends State<SubjectInformation> {
    final myController = TextEditingController();
    String _dropdownValue = "Parcial 1";

    @override
    Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.materia.name),
        ),
        body: Center(
            child: ListView(
                children: <Widget>[
                    getCalificaciones(widget.materia.parciales),
                    Container(
                        height: 50,
                        child: ListView(
                            padding: const EdgeInsets.all(8),
                            children: [
                                ListTile(
                                    title: Text('Ordinario: 8.0'),
                                ),
                            ]
                        )
                    )
                ],
            ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                        return AlertDialog(
                            title: const Text("Guardar calificación"),
                            content: SingleChildScrollView(
                                child: ListBody(
                                    children: <Widget>[
                                        DropdownButtonFormField<String>(
                                            value: _dropdownValue,
                                            items: getParciales(widget.materia.parciales).map((String value) {
                                                return DropdownMenuItem<String>(
                                                    child: Text(value),
                                                    value: value,
                                                );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                                setState(()  => _dropdownValue = newValue!);
                                            },
                                            onSaved: (String? newValue) {
                                                setState(()  => _dropdownValue = newValue!);
                                            },
                                        ),
                                        TextField(
                                            controller: myController,
                                        ),
                                    ],
                                ),
                            ),
                            actions: <Widget>[
                                TextButton(
                                    onPressed: () => Navigator.pop(context, 'Cancelar'),
                                    child: const Text('Cancelar'),
                                ),
                                TextButton(
                                    onPressed: () => Navigator.pop(context, 'Guardar'),
                                    child: const Text('Guardar'),
                                ),
                            ],
                        );
                    }
                );
            },
            child: const Icon(Icons.add),
        )
    );
    }
  //Calificaciones
  Container getCalificaciones(int parciales) {
    return Container(
      height: 55 * parciales.toDouble(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: parciales,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text('Parcial ${index+1}: 8.0'),
          );
        },
      ),
    );
  }

  List<String> getParciales(int parciales){
    return List.generate(
        parciales,
        (index) => 'Parcial ${index+1}',
    );
  }
}
