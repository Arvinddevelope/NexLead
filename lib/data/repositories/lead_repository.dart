import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/services/lead_service.dart';

class LeadRepository {
  final LeadService _leadService;

  LeadRepository(this._leadService);

  /// Get all leads
  Future<List<Lead>> getAllLeads() async {
    return await _leadService.getAllLeads();
  }

  /// Get lead by ID
  Future<Lead> getLeadById(String id) async {
    return await _leadService.getLeadById(id);
  }

  /// Get leads by user ID
  Future<List<Lead>> getLeadsByUserId(String userId) async {
    return await _leadService.getLeadsByUserId(userId);
  }

  /// Create a new lead
  Future<Lead> createLead(Lead lead) async {
    return await _leadService.createLead(lead);
  }

  /// Update an existing lead
  Future<Lead> updateLead(Lead lead) async {
    return await _leadService.updateLead(lead);
  }

  /// Delete a lead
  Future<void> deleteLead(String id) async {
    return await _leadService.deleteLead(id);
  }
}
