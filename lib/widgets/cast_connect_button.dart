import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

import '../../blocs/cast_session/cast_session_bloc.dart';

class CastConnectButton extends StatelessWidget {
  const CastConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CastSessionBloc, CastSessionState>(
      builder: (context, state) {
        // Connecté → on affiche le nom de l'appareil + icône verte
        if (state is CastSessionConnected) {
          return GestureDetector(
            onTap: () => _showDisconnectDialog(context, state.deviceName),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cast_connected, color: Colors.green, size: 20),
                const SizedBox(width: 6),
                Text(
                  state.deviceName,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // En cours de connexion → loader
        if (state is CastSessionConnecting) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Connexion à ${state.device.friendlyName}...',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          );
        }

        // Déconnecté / initial → bouton pour scanner les appareils
        return ElevatedButton.icon(
          onPressed: () => _showDeviceList(context),
          icon: const Icon(Icons.cast, size: 18),
          label: const Text('Connecter'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      },
    );
  }

  // Bottom sheet avec la liste des appareils disponibles
  void _showDeviceList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CastSessionBloc>(),
        child: const _DeviceListSheet(),
      ),
    );
  }

  // Dialog de confirmation de déconnexion
  void _showDisconnectDialog(BuildContext context, String deviceName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnecter'),
        content: Text('Se déconnecter de "$deviceName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<CastSessionBloc>().add(
                CastSessionDisconnectRequested(),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Liste des appareils découverts sur le réseau
class _DeviceListSheet extends StatelessWidget {
  const _DeviceListSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Poignée
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Appareils disponibles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),

        // Stream des appareils découverts
        StreamBuilder<List<GoogleCastDevice>>(
          stream: GoogleCastDiscoveryManager.instance.devicesStream,
          builder: (context, snapshot) {
            final devices = snapshot.data ?? [];

            if (devices.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Recherche d\'appareils...'),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: const Icon(Icons.cast),
                  title: Text(device.friendlyName ?? 'Appareil inconnu'),
                  subtitle: Text(device.modelName ?? ''),
                  onTap: () {
                    context.read<CastSessionBloc>().add(
                      CastSessionDeviceSelected(device),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
