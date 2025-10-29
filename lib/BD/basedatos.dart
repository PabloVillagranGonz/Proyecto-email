import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseDeDatos {
  static final BaseDeDatos _instance = BaseDeDatos._internal();
  static Database? _dbInstance;

  factory BaseDeDatos() {
    return _instance;
  }

  BaseDeDatos._internal();

  Future<Database> get database async {
    if (_dbInstance != null) return _dbInstance!;
    _dbInstance = await initDatabase();
    return _dbInstance!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    print('Ruta de la base de datos: $dbPath');
    final path = join(dbPath, 'centrosnet.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS correos');
          await db.execute('DROP TABLE IF EXISTS users');
          await _onCreate(db, newVersion);
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        email TEXT UNIQUE,
        password TEXT NOT NULL,
        tipo TEXT NOT NULL
      )

    ''');

    await db.execute('''
      CREATE TABLE correos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        destinatario_id INTEGER NOT NULL,
        asunto TEXT NOT NULL,
        cuerpo TEXT NOT NULL,
        fecha_envio TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (destinatario_id) REFERENCES users (id)
      );

    ''');

    await db.execute('''
      CREATE TABLE usuarios_correos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        correo_id INTEGER NOT NULL,
        usuario_id INTEGER NOT NULL,
        leido INTEGER NOT NULL DEFAULT 0,
        eliminado INTEGER NOT NULL DEFAULT 0,
        archivado INTEGER NOT NULL DEFAULT 0,
        fecha_leido TEXT DEFAULT NULL,
        fecha_eliminado TEXT DEFAULT NULL,
        FOREIGN KEY (correo_id) REFERENCES correos (id) ON DELETE CASCADE,
        FOREIGN KEY (usuario_id) REFERENCES users (id) ON DELETE CASCADE
    );
    ''');
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<int> insertUser(String nombre, String apellidos, String email,
      String password, String tipo) async {
    final db = await database;

    final exists = await userExists(email);
    if (exists) {
      throw Exception('El correo ya está registrado');
    }

    final userId = await db.insert(
      'users',
      {
        'nombre': nombre,
        'apellidos': apellidos,
        'email': email,
        'password': password,
        'tipo': tipo,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setString('user_email', email);
    print('Usuario registrado con ID: $userId y correo: $email');

    return userId;
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      print('Usuario iniciado sesión con email: $email');

      return result.first;
    }
    return null;
  }

  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }

  Future<void> updatePassword(String email, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> insertCorreo(int userId, String asunto, String cuerpo,
      String tipo, int destinatarioId) async {
    final db = await database;

    final usuario = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [destinatarioId],
    );

    if (usuario.isEmpty) {
      throw Exception('El destinatario no existe');
    }

    if (tipo != 'alumno' && tipo != 'profesor') {
      throw Exception('El tipo debe ser "alumno" o "profesor"');
    }

    return await db.insert(
      'correos',
      {
        'user_id': userId,
        'destinatario_id': destinatarioId,
        'asunto': asunto,
        'cuerpo': cuerpo,
        'fecha_envio': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCorreosEnviadosPorUsuario(
      String email) async {
    final db = await database;
    print('Obteniendo correos enviados por el usuario con correo: $email');

    final List<Map<String, dynamic>> correos = await db.rawQuery('''
      SELECT correos.*, users.nombre, users.email
      FROM correos
      INNER JOIN users ON correos.user_id = users.id
      WHERE users.email = ?
    ''', [email]);

    print('Correos obtenidos: $correos');
    return correos;
  }

  Future<Map<String, dynamic>?> getCorreoById(int correoId) async {
    final db = await database;
    final result = await db.query(
      'correos',
      where: 'id = ?',
      whereArgs: [correoId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getCorreosPorTipo(
      String email, String tipo) async {
    final db = await database;
    print(
        'Obteniendo correos del tipo: $tipo para el usuario con correo: $email');

    if (tipo != 'alumno' && tipo != 'profesor') {
      throw Exception('El tipo de filtro debe ser "alumno" o "profesor".');
    }

    final List<Map<String, dynamic>> usuario = await db.rawQuery('''
      SELECT id FROM users WHERE email = ?
    ''', [email]);

    print('Usuario encontrado con ID: $usuario');

    if (usuario.isEmpty) {
      throw Exception('Usuario no encontrado');
    }

    final destinatarioId = usuario.first['id'];

    final List<Map<String, dynamic>> correos = await db.rawQuery('''
      SELECT 
        correos.*, 
        users.nombre, 
        users.email,
        IFNULL(usuarios_correos.leido, 0) AS leido
      FROM correos
      INNER JOIN users ON correos.user_id = users.id
      LEFT JOIN usuarios_correos ON correos.id = usuarios_correos.correo_id AND usuarios_correos.usuario_id = ?
      WHERE correos.destinatario_id = ? AND users.tipo = ? AND correos.id NOT IN (
        SELECT correo_id FROM usuarios_correos WHERE usuario_id = ? AND eliminado = 1
      )
    ''', [destinatarioId, destinatarioId, tipo, destinatarioId]);

    print('Correos obtenidos: $correos');

    return correos;
  }

  Future<void> eliminarCorreoParaUsuario(int correoId, int usuarioId) async {
    final db = await database;
    final fechaEliminacion = DateTime.now().toIso8601String();

    try {
      final existingRecord = await db.query(
        'usuarios_correos',
        where: 'correo_id = ? AND usuario_id = ?',
        whereArgs: [correoId, usuarioId],
      );

      if (existingRecord.isNotEmpty) {
        await db.update(
          'usuarios_correos',
          {
            'eliminado': 1,
            'fecha_eliminado': fechaEliminacion,
          },
          where: 'correo_id = ? AND usuario_id = ?',
          whereArgs: [correoId, usuarioId],
        );
      } else {
        await db.insert(
          'usuarios_correos',
          {
            'correo_id': correoId,
            'usuario_id': usuarioId,
            'eliminado': 1,
            'fecha_eliminado': fechaEliminacion,
            'leido': 0,
            'archivado': 0,
          },
        );
      }
    } catch (e) {
      throw Exception('Error al marcar el correo como eliminado: $e');
    }
  }

  Future<void> marcarCorreoComoLeido(int correoId, int usuarioId) async {
    final db = await database;
    final fechaLeido = DateTime.now().toIso8601String();

    try {
      print("Verificando si el correo ya está en la BD...");
      final existingRecord = await db.query(
        'usuarios_correos',
        where: 'correo_id = ? AND usuario_id = ?',
        whereArgs: [correoId, usuarioId],
      );

      print("Registros antes de actualizar: $existingRecord");

      if (existingRecord.isNotEmpty) {
        int updated = await db.update(
          'usuarios_correos',
          {
            'leido': 1,
            'fecha_leido': fechaLeido,
          },
          where: 'correo_id = ? AND usuario_id = ?',
          whereArgs: [correoId, usuarioId],
        );

        print("Registros actualizados: $updated");
      } else {
        int inserted = await db.insert(
          'usuarios_correos',
          {
            'correo_id': correoId,
            'usuario_id': usuarioId,
            'leido': 1,
            'fecha_leido': fechaLeido,
            'eliminado': 0,
            'archivado': 0,
          },
        );

        print("Nuevo registro insertado con ID: $inserted");
      }

      final testQuery = await db.query(
        'usuarios_correos',
        where: 'correo_id = ? AND usuario_id = ?',
        whereArgs: [correoId, usuarioId],
      );
      print("Estado después de marcar como leído: $testQuery");
    } catch (e) {
      print('Error al marcar el correo como leído: $e');
      throw Exception('Error al marcar el correo como leído: $e');
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['password'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      String storedPassword = result.first['password'] as String;
      return storedPassword == password;
    }

    return false;
  }

  Future<Map<String, int>> obtenerCorreosEnviadosYRecibidos(
      String email) async {
    final db = await BaseDeDatos().database;

    final userIdQuery = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (userIdQuery.isEmpty) {
      throw Exception('Usuario no encontrado con el correo: $email');
    }

    final userId = userIdQuery.first['id'];

    final enviados = Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) 
      FROM correos 
      WHERE user_id = ?
    ''', [userId]),
        ) ??
        0;

    final recibidos = Sqflite.firstIntValue(
          await db.rawQuery('''
      SELECT COUNT(*) 
      FROM correos 
      WHERE destinatario_id = ?
    ''', [userId]),
        ) ??
        0;

    return {
      'enviados': enviados,
      'recibidos': recibidos,
    };
  }

  Future<void> deleteUserByEmail(String email) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}
